require "test_helper"

class TymeTest < Minitest::Test

  TMP_DB = 'test/tmp/test.yml'

  def test_that_it_has_a_version_number
    refute_nil ::Tyme::VERSION
  end

  def test_last_process
    db_name = 'last_process'
    last = Tyme::Last.new( StringIO.new(get_last(1)) )
    assert last.process == get_db_expect(db_name)
  end

  def test_empty_db
    db = Tyme::Db.new(TMP_DB)
    db.add_entry(:user1, :'2018-06-03', 123)
    db.save
    assert get_db_modif == get_db_expect('empty_db')
  end

  def test_empty_db_without_dir
    db_path = 'test/tmp/doesnotexist'
    db_file = db_path + '/db.yml'
    # make sure directory does not exist before running test
    assert Dir.exist?(db_path) == false

    db = Tyme::Db.new(db_file)
    db.add_entry(:user1, :'2018-06-03', 123)
    db.save
    res = YAML.load_file(db_file)
    FileUtils.remove_entry_secure db_path
    assert res == get_db_expect('empty_db')
  end

  def test_existing_db_overwrite_value
    db_name = 'existing_db_overwrite_value'
    copy_db 'existing_db1'
    db = Tyme::Db.new(TMP_DB)
    db.add_entry(:user1, :'2018-06-03', 123)
    db.save
    assert get_db_modif == get_db_expect( db_name )
  end

  def test_existing_db_add_value_to_existing_user
    db_name = 'existing_db_add_value_to_existing_user'
    copy_db 'existing_db1'
    db = Tyme::Db.new(TMP_DB)
    db.add_entry(:user1, :'2018-06-01', 137)
    db.save
    assert get_db_modif == get_db_expect( db_name )
  end
  
  def test_existing_db_add_user
    db_name = 'existing_db_add_user'
    copy_db 'existing_db1'
    db = Tyme::Db.new(TMP_DB)
    db.add_entry(:user3, :'2018-05-31', 179)
    db.save
    assert get_db_modif == get_db_expect( db_name )
  end

  def test_manager
    db_name = 'manager'
    manager = Tyme::Manager.new(TMP_DB, StringIO.new(get_last(1)))
    manager.run
    assert get_db_modif == get_db_expect( db_name )
  end

  # HELPERS
  private
    def copy_db name
      FileUtils.cp "test/fixtures/#{name}.yml", TMP_DB
    end

    def get_db_modif
      ret = YAML.load_file(TMP_DB)
      File.delete(TMP_DB)
      ret
    end

    def get_db_expect name
      YAML.load_file("test/fixtures/#{name}_result.yml")
    end
    
    def get_last(num)
      File.read("test/fixtures/last#{num.to_s}.txt")
    end
end
