# frozen_string_literal: true

RSpec.describe RubyLint::Cop::InternalAffairs::MethodNameEqual do
  subject(:cop) { described_class.new(config) }

  let(:config) { RubyLint::Config.new }

  it 'registers an offense when using `#method == :do_something`' do
    expect_offense(<<~RUBY)
      node.method_name == :do_something
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method?(:do_something)` instead of `method_name == :do_something`.
    RUBY

    expect_correction(<<~RUBY)
      node.method?(:do_something)
    RUBY
  end

  it 'registers an offense when using `#method == other_node.do_something`' do
    expect_offense(<<~RUBY)
      node.method_name == other_node.do_something
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `method?(other_node.do_something)` instead of `method_name == other_node.do_something`.
    RUBY

    expect_correction(<<~RUBY)
      node.method?(other_node.do_something)
    RUBY
  end

  it 'does not register an offense when using `#method?`' do
    expect_no_offenses(<<~RUBY)
      node.method?(:do_something)
    RUBY
  end
end