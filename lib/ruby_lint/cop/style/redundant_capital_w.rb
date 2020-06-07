# frozen_string_literal: true

module RubyLint
  module Cop
    module Style
      # This cop checks for usage of the %W() syntax when %w() would do.
      #
      # @example
      #   # bad
      #   %W(cat dog pig)
      #   %W[door wall floor]
      #
      #   # good
      #   %w/swim run bike/
      #   %w[shirt pants shoes]
      #   %W(apple #{fruit} grape)
      class RedundantCapitalW < Cop
        include PercentLiteral

        MSG = 'Do not use `%W` unless interpolation is needed. ' \
              'If not, use `%w`.'

        def on_array(node)
          process(node, '%W')
        end

        def autocorrect(node)
          lambda do |corrector|
            src = node.loc.begin.source
            corrector.replace(node.loc.begin, src.tr('W', 'w'))
          end
        end

        private

        def on_percent_literal(node)
          return if requires_interpolation?(node)

          add_offense(node)
        end

        def requires_interpolation?(node)
          node.child_nodes.any? do |string|
            string.dstr_type? ||
              double_quotes_required?(string.source)
          end
        end
      end
    end
  end
end