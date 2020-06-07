# frozen_string_literal: true

RSpec.describe RubyLint::Cop::Style::CaseEquality do
  subject(:cop) { described_class.new(config) }

  let(:config) { RubyLint::Config.new }

  it 'registers an offense for ===' do
    expect_offense(<<~RUBY)
      Array === var
            ^^^ Avoid the use of the case equality operator `===`.
    RUBY
  end

  context 'when constant checks are allowed' do
    let(:config) do
      RubyLint::Config.new(
        'Style/CaseEquality' => {
          'AllowOnConstant' => true
        }
      )
    end

    it 'does not fail when the receiver is implicit' do
      expect_no_offenses(<<~RUBY)
        puts "No offense"
      RUBY
    end

    it 'does not register an offense for === when the receiver is a constant' do
      expect_no_offenses(<<~RUBY)
        Array === var
      RUBY
    end

    it 'registers an offense for === when the receiver is not a constant' do
      expect_offense(<<~RUBY)
        /OMG/ === "OMG"
              ^^^ Avoid the use of the case equality operator `===`.
      RUBY
    end
  end
end
