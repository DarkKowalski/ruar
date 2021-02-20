# frozen_string_literal: true

require 'test_helper'

class RequireTest < Minitest::Test
  def setup
    archive = File.join(Dir.tmpdir, 'plain.ruar')
    Ruar::Serialize.plain('./test/sample', archive)
    Ruar.setup(
      archive: archive
    ).activate
  end

  def test_ruar_can_require_plain_def
    result = require 'dir/plain_def_in_dir'

    assert_equal(true, result)
    plain_def_in_dir

    Object.undef_method :plain_def_in_dir
    $LOADED_FEATURES.pop
  end

  def test_ruar_cannot_require_twice
    first = require 'dir/plain_def_in_dir'
    second = require 'dir/plain_def_in_dir'

    assert_equal(true, first)
    assert_equal(false, second)
    plain_def_in_dir

    Object.undef_method :plain_def_in_dir
    $LOADED_FEATURES.pop
  end

  def test_ruar_require_raise_load_error_when_cannot_find_the_file
    assert_raises(LoadError) do
      require 'no_dir/no_file'
    end
  end

  def test_ruar_can_load_plain_def
    result = load 'dir/plain_def_in_dir'
    assert_equal(true, result)
    plain_def_in_dir

    Object.undef_method :plain_def_in_dir
  end

  def test_ruar_can_load_twice
    first = load 'dir/plain_def_in_dir'
    second = load 'dir/plain_def_in_dir'

    assert_equal(true, first)
    assert_equal(true, second)
    plain_def_in_dir

    Object.undef_method :plain_def_in_dir
  end

  def test_ruar_load_raise_load_error_when_cannot_find_the_file
    assert_raises(LoadError) do
      load 'no_dir/no_file'
    end
  end

  # TODO: add more tests
end
