require 'rspec/core/formatters/helpers'
require 'set'

module RSpec
  module Core
    module Formatters
      class DeprecationFormatter
        attr_reader :count, :deprecation_stream, :summary_stream

        def initialize(deprecation_stream, summary_stream)
          @deprecation_stream = deprecation_stream
          @summary_stream = summary_stream
          @seen_deprecations = Set.new
          @count = 0
        end

        def printer
          @printer ||= case deprecation_stream
                       when File, RaiseErrorStream
                         ImmediatePrinter.new(deprecation_stream, summary_stream, self)
                       else
                         DelayedPrinter.new(deprecation_stream, summary_stream, self)
                       end
        end

        def deprecation(data)
          return if @seen_deprecations.include?(data)

          @count += 1
          printer.print_deprecation_message data
          @seen_deprecations << data
        end

        def deprecation_summary
          printer.deprecation_summary
        end

        def deprecation_message_for(data)
          if data[:message]
            SpecifiedDeprecationMessage.new(data)
          else
            GeneratedDeprecationMessage.new(data)
          end
        end

        RAISE_ERROR_CONFIG_NOTICE = <<-EOS.gsub(/^\s+\|/, '')
          |
          |If you need more of the backtrace for any of these deprecations to
          |identify where to make the necessary changes, you can configure
          |`config.raise_errors_for_deprecations!`, and it will turn the
          |deprecation warnings into errors, giving you the full backtrace.
        EOS

        SpecifiedDeprecationMessage = Struct.new(:type) do
          def initialize(data)
            @message = data[:message]
            super deprecation_type_for(data)
          end

          def to_s
            @message
          end

          def too_many_warnings_message
            msg = "Too many similar deprecation messages reported, disregarding further reports."
            msg << " Set config.deprecation_stream to a File for full output."
            msg
          end

          private

          def deprecation_type_for(data)
            data[:message].gsub(/(\w+\/)+\w+\.rb:\d+/, '')
          end
        end

        GeneratedDeprecationMessage = Struct.new(:type) do
          def initialize(data)
            @data = data
            super data[:deprecated]
          end

          def to_s
            msg =  "#{@data[:deprecated]} is deprecated."
            msg << " Use #{@data[:replacement]} instead." if @data[:replacement]
            msg << " Called from #{@data[:call_site]}." if @data[:call_site]
            msg
          end

          def too_many_warnings_message
            msg = "Too many uses of deprecated '#{type}'."
            msg << " Set config.deprecation_stream to a File for full output."
            msg
          end
        end

        class ImmediatePrinter
          include ::RSpec::Core::Formatters::Helpers

          attr_reader :deprecation_stream, :summary_stream, :deprecation_formatter

          def initialize(deprecation_stream, summary_stream, deprecation_formatter)
            @deprecation_stream = deprecation_stream

            # In one of my test suites, I got lots of duplicate output in the
            # deprecation file (e.g. 200 of the same deprecation, even though
            # the `puts` below was only called 6 times). Setting `sync = true`
            # fixes this (but we really have no idea why!).
            @deprecation_stream.sync = true

            @summary_stream = summary_stream
            @deprecation_formatter = deprecation_formatter
          end

          def print_deprecation_message(data)
            deprecation_message = deprecation_formatter.deprecation_message_for(data)
            deprecation_stream.puts deprecation_message.to_s
          end

          def deprecation_summary
            if deprecation_formatter.count > 0
              summary_stream.puts "\n#{pluralize(deprecation_formatter.count, 'deprecation')} logged to #{deprecation_stream.path}"
              deprecation_stream.puts RAISE_ERROR_CONFIG_NOTICE
            end
          end
        end

        class DelayedPrinter
          TOO_MANY_USES_LIMIT = 4

          include ::RSpec::Core::Formatters::Helpers

          attr_reader :deprecation_stream, :summary_stream, :deprecation_formatter

          def initialize(deprecation_stream, summary_stream, deprecation_formatter)
            @deprecation_stream = deprecation_stream
            @summary_stream = summary_stream
            @deprecation_formatter = deprecation_formatter
            @seen_deprecations = Hash.new { 0 }
            @deprecation_messages = Hash.new { |h, k| h[k] = [] }
          end

          def print_deprecation_message(data)
            deprecation_message = deprecation_formatter.deprecation_message_for(data)
            @seen_deprecations[deprecation_message] += 1

            stash_deprecation_message(deprecation_message)
          end

          def stash_deprecation_message(deprecation_message)
            if @seen_deprecations[deprecation_message] < TOO_MANY_USES_LIMIT
              @deprecation_messages[deprecation_message] << deprecation_message.to_s
            elsif @seen_deprecations[deprecation_message] == TOO_MANY_USES_LIMIT
              @deprecation_messages[deprecation_message] << deprecation_message.too_many_warnings_message
            end
          end

          def deprecation_summary
            return unless @deprecation_messages.any?

            print_deferred_deprecation_warnings
            deprecation_stream.puts RAISE_ERROR_CONFIG_NOTICE

            summary_stream.puts "\n#{pluralize(deprecation_formatter.count, 'deprecation warning')} total"
          end

          def print_deferred_deprecation_warnings
            deprecation_stream.puts "\nDeprecation Warnings:\n\n"
            @deprecation_messages.keys.sort_by(&:type).each do |deprecation|
              messages = @deprecation_messages[deprecation]
              messages.each { |msg| deprecation_stream.puts msg }
              deprecation_stream.puts
            end
          end
        end

        # Not really a stream, but is usable in place of one.
        class RaiseErrorStream
          def puts(message)
            raise DeprecationError, message
          end

          def sync=(value)
            # no-op
          end
        end

      end
    end

    DeprecationError = Class.new(StandardError)
  end
end
