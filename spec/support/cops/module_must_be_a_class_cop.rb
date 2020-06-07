# frozen_string_literal: true

module RubyLint
  module Cop
    module Test
      class ModuleMustBeAClassCop < RubyLint::Cop::Cop
        def on_module(node)
          add_offense(node, message: 'Module must be a Class')
        end

        def autocorrect(node)
          ->(corrector) { corrector.replace(node.loc.keyword, 'class') }
        end
      end
    end
  end
end
