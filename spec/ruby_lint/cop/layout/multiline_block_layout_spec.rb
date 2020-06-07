# frozen_string_literal: true

RSpec.describe RubyLint::Cop::Layout::MultilineBlockLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing newline in do/end block w/o params' do
    expect_offense(<<~RUBY)
      test do foo
              ^^^ Block body expression is on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do 
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects for missing newline ' \
    'in {} block w/o params' do
    expect_offense(<<~RUBY)
      test { foo
             ^^^ Block body expression is on the same line as the block start.
      }
    RUBY

    expect_correction(<<~RUBY)
      test { 
        foo
      }
    RUBY
  end

  it 'registers an offense and corrects for missing newline ' \
    'in do/end block with params' do
    expect_offense(<<~RUBY)
      test do |x| foo
                  ^^^ Block body expression is on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x| 
        foo
      end
    RUBY
  end

  it 'registers an offense and corrects for missing newline ' \
    'in {} block with params' do
    expect_offense(<<~RUBY)
      test { |x| foo
                 ^^^ Block body expression is on the same line as the block start.
      }
    RUBY

    expect_correction(<<~RUBY)
      test { |x| 
        foo
      }
    RUBY
  end

  it 'does not register an offense for one-line do/end blocks' do
    expect_no_offenses('test do foo end')
  end

  it 'does not register an offense for one-line {} blocks' do
    expect_no_offenses('test { foo }')
  end

  it 'does not register offenses when there is a newline for do/end block' do
    expect_no_offenses(<<~RUBY)
      test do
        foo
      end
    RUBY
  end

  it 'does not register offenses when there are too many parameters to fit ' \
     'on one line' do
    expect_no_offenses(<<~RUBY)
      some_result = lambda do |
        so_many,
        parameters,
        it_will,
        be_too_long,
        for_one_line|
        do_something
      end
    RUBY
  end

  it 'does not error out when the block is empty' do
    expect_no_offenses(<<~RUBY)
      test do |x|
      end
    RUBY
  end

  it 'does not register offenses when there is a newline for {} block' do
    expect_no_offenses(<<~RUBY)
      test {
        foo
      }
    RUBY
  end

  it 'registers offenses and corrects for lambdas' do
    expect_offense(<<~RUBY)
      -> (x) do foo
                ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      -> (x) do 
        foo
        bar
      end
    RUBY
  end

  it 'registers offenses and corrrects for new lambda literal syntax' do
    expect_offense(<<~RUBY)
      -> x do foo
              ^^^ Block body expression is on the same line as the block start.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      -> x do 
        foo
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects line-break before arguments' do
    expect_offense(<<~RUBY)
      test do
        |x| play_with(x)
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x|
        play_with(x)
      end
    RUBY
  end

  it 'registers an offense and corrects line-break ' \
    'before arguments with empty block' do
    expect_offense(<<~RUBY)
      test do
        |x|
        ^^^ Block argument expression is not on the same line as the block start.
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x|
      end
    RUBY
  end

  it 'registers an offense and corrects line-break within arguments' do
    expect_offense(<<~RUBY)
      test do |x,
              ^^^ Block argument expression is not on the same line as the block start.
        y|
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x, y|
      end
    RUBY
  end

  it 'registers an offense and corrects a do/end block with a mult-line body' do
    expect_offense(<<~RUBY)
      test do |foo| bar
                    ^^^ Block body expression is on the same line as the block start.
        test
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |foo| 
        bar
        test
      end
    RUBY
  end

  it 'autocorrects in more complex case with lambda and assignment, and '\
     'aligns the next line two spaces out from the start of the block' do
    expect_offense(<<~RUBY)
      x = -> (y) { foo
                   ^^^ Block body expression is on the same line as the block start.
        bar
      }
    RUBY

    expect_correction(<<~RUBY)
      x = -> (y) { 
            foo
        bar
      }
    RUBY
  end

  it 'registers an offense and corrects a line-break within arguments' do
    expect_offense(<<~RUBY)
      test do |x,
              ^^^ Block argument expression is not on the same line as the block start.
        y| play_with(x, y)
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |x, y|
        play_with(x, y)
      end
    RUBY
  end

  it 'registers an offense and corrects a line break ' \
    'within destructured arguments' do
    expect_offense(<<~RUBY)
      test do |(x,
              ^^^^ Block argument expression is not on the same line as the block start.
        y)| play_with(x, y)
      end
    RUBY

    expect_correction(<<~RUBY)
      test do |(x, y)|
        play_with(x, y)
      end
    RUBY
  end

  it "doesn't move end keyword in a way which causes infinite loop " \
     'in combination with Style/BlockEndNewLine' do
    expect_offense(<<~RUBY)
      def f
        X.map do |(a,
                 ^^^^ Block argument expression is not on the same line as the block start.
        b)|
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |(a, b)|
        end
      end
    RUBY
  end

  it 'does not auto-correct a trailing comma when only one argument ' \
     'is present' do
    expect_offense(<<~RUBY)
      def f
        X.map do |
                 ^ Block argument expression is not on the same line as the block start.
          a,
        |
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |a,|
        end
      end
    RUBY
  end

  it 'auto-corrects nested parens correctly' do
    expect_offense(<<~RUBY)
      def f
        X.map do |
                 ^ Block argument expression is not on the same line as the block start.
          (((a), b), c)
        |
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def f
        X.map do |(((a), b), c)|
        end
      end
    RUBY
  end
end