# frozen_string_literal: true

RSpec.describe RubyLint::Cop::Generator::RequireFileInjector do
  let(:stdout) { StringIO.new }
  let(:root_file_path) { 'lib/root.rb' }
  let(:injector) do
    described_class.new(
      source_path: source_path,
      root_file_path: root_file_path,
      output: stdout
    )
  end

  around do |example|
    Dir.mktmpdir('ruby_lint-require_file_injector_spec-') do |dir|
      RubyLint::PathUtil.chdir(dir) do
        Dir.mkdir('lib')
        example.run
      end
    end
  end

  context 'when a `require_relative` entry does not exist from before' do
    let(:source_path) { 'lib/ruby_lint/cop/style/fake_cop.rb' }

    before do
      File.write(root_file_path, <<~RUBY)
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'ruby_lint/version'

        require_relative 'ruby_lint/cop/lint/flip_flop'

        require_relative 'ruby_lint/cop/style/end_block'
        require_relative 'ruby_lint/cop/style/even_odd'
        require_relative 'ruby_lint/cop/style/file_name'

        require_relative 'ruby_lint/cop/rails/action_filter'

        require_relative 'ruby_lint/cop/team'
      RUBY
    end

    it 'injects a `require_relative` statement ' \
       'on the right line in the root file' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'ruby_lint/version'

        require_relative 'ruby_lint/cop/lint/flip_flop'

        require_relative 'ruby_lint/cop/style/end_block'
        require_relative 'ruby_lint/cop/style/even_odd'
        require_relative 'ruby_lint/cop/style/fake_cop'
        require_relative 'ruby_lint/cop/style/file_name'

        require_relative 'ruby_lint/cop/rails/action_filter'

        require_relative 'ruby_lint/cop/team'
      RUBY

      injector.inject

      expect(File.read(root_file_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/root.rb - `require_relative 'ruby_lint/cop/style/fake_cop'` was injected.
      MESSAGE
    end
  end

  context 'when a cop of style department already exists' do
    let(:source_path) { 'lib/ruby_lint/cop/style/the_end_of_style.rb' }

    before do
      File.write(root_file_path, <<~RUBY)
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'ruby_lint/version'

        require_relative 'ruby_lint/cop/lint/flip_flop'

        require_relative 'ruby_lint/cop/style/end_block'
        require_relative 'ruby_lint/cop/style/even_odd'
        require_relative 'ruby_lint/cop/style/file_name'

        require_relative 'ruby_lint/cop/rails/action_filter'

        require_relative 'ruby_lint/cop/team'
      RUBY
    end

    it 'injects a `require_relative` statement ' \
       'on the end of style department' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'ruby_lint/version'

        require_relative 'ruby_lint/cop/lint/flip_flop'

        require_relative 'ruby_lint/cop/style/end_block'
        require_relative 'ruby_lint/cop/style/even_odd'
        require_relative 'ruby_lint/cop/style/file_name'
        require_relative 'ruby_lint/cop/style/the_end_of_style'

        require_relative 'ruby_lint/cop/rails/action_filter'

        require_relative 'ruby_lint/cop/team'
      RUBY

      injector.inject

      expect(File.read(root_file_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/root.rb - `require_relative 'ruby_lint/cop/style/the_end_of_style'` was injected.
      MESSAGE
    end
  end

  context 'when a `require` entry already exists' do
    let(:source_path) { 'lib/ruby_lint/cop/style/fake_cop.rb' }
    let(:source) { <<~RUBY }
      # frozen_string_literal: true

      require 'parser'
      require 'rainbow'

      require 'English'
      require 'set'
      require 'forwardable'

      require_relative 'ruby_lint/version'

      require_relative 'ruby_lint/cop/lint/flip_flop'

      require_relative 'ruby_lint/cop/style/end_block'
      require_relative 'ruby_lint/cop/style/even_odd'
      require_relative 'ruby_lint/cop/style/fake_cop'
      require_relative 'ruby_lint/cop/style/file_name'

      require_relative 'ruby_lint/cop/rails/action_filter'

      require_relative 'ruby_lint/cop/team'
    RUBY

    before do
      File.write(root_file_path, source)
    end

    it 'does not write to any file' do
      injector.inject

      expect(File.read(root_file_path)).to eq source
      expect(stdout.string.empty?).to be(true)
    end
  end

  context 'when using an unknown department' do
    let(:source_path) { 'lib/ruby_lint/cop/unknown/fake_cop.rb' }

    let(:source) { <<~RUBY }
      # frozen_string_literal: true

      require 'parser'
      require 'rainbow'

      require 'English'
      require 'set'
      require 'forwardable'

      require_relative 'ruby_lint/version'

      require_relative 'ruby_lint/cop/lint/flip_flop'

      require_relative 'ruby_lint/cop/style/end_block'
      require_relative 'ruby_lint/cop/style/even_odd'
      require_relative 'ruby_lint/cop/style/fake_cop'
      require_relative 'ruby_lint/cop/style/file_name'

      require_relative 'ruby_lint/cop/rails/action_filter'

      require_relative 'ruby_lint/cop/team'
    RUBY

    before do
      File.write(root_file_path, source)
    end

    it 'inserts a `require_relative` statement to the bottom of the file' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        require 'parser'
        require 'rainbow'

        require 'English'
        require 'set'
        require 'forwardable'

        require_relative 'ruby_lint/version'

        require_relative 'ruby_lint/cop/lint/flip_flop'

        require_relative 'ruby_lint/cop/style/end_block'
        require_relative 'ruby_lint/cop/style/even_odd'
        require_relative 'ruby_lint/cop/style/fake_cop'
        require_relative 'ruby_lint/cop/style/file_name'

        require_relative 'ruby_lint/cop/rails/action_filter'

        require_relative 'ruby_lint/cop/team'
        require_relative 'ruby_lint/cop/unknown/fake_cop'
      RUBY

      injector.inject

      expect(File.read(root_file_path)).to eq generated_source
      expect(stdout.string).to eq(<<~MESSAGE)
        [modify] lib/root.rb - `require_relative 'ruby_lint/cop/unknown/fake_cop'` was injected.
      MESSAGE
    end
  end
end
