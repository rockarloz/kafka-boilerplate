# frozen_string_literal: true

# Generates a simple boilerplate for a Kafka consumer
class ConsumerGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :topic, type: :string, banner: 'topic', required: true

  def call
    add_topic_consumer if generating?
    delete_topic_consumer if destroying?

    template 'consumer.erb', "app/consumers/#{file_name}.rb"
  end

  protected

  def consumer_template
    [
      "\r",
      "    topic :#{topic} do",
      "      consumer #{class_name}",
      '    end'
    ].join("\n")
  end

  def generating?
    behavior == :invoke
  end

  def destroying?
    behavior == :revoke
  end

  def config_file
    @config_file ||= File.open('karafka.rb', 'rb', &:read)
  end

  def add_topic_consumer
    append_from = 'consumer_groups.draw do'
    gsub_file 'karafka.rb', /(#{Regexp.escape(append_from)})/mi do |match|
      "#{match}#{consumer_template}"
    end
  end

  def delete_topic_consumer
    return unless config_file.match?(/#{consumer_template}/mi)

    modified = config_file.sub(/#{consumer_template}/mi, '')
    File.open('karafka.rb', 'wb') { |file| file.write(modified) }
  end
end
