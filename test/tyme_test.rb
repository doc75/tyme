require "test_helper"

class TymeTest < Minitest::Test
  LAST_OUTPUT='user30   tty7         2018-06-03T09:02:01+0200   gone - no logout
user10   tty9         2018-06-02T19:07:55+0200 - 2018-06-02T19:41:40+0200  (00:33)
user20   tty8         2018-06-02T18:59:51+0200 - crash                     (14:01)
user10   tty8         2018-06-02T17:27:41+0200 - 2018-06-02T17:28:15+0200  (00:00)
user30   tty7         2018-06-02T17:00:16+0200 - crash                     (16:01)
user30   tty7         2018-06-02T16:55:11+0200 - 2018-06-02T16:59:55+0200  (00:04)
user30   tty7         2018-06-02T14:49:39+0200 - 2018-06-02T16:55:06+0200  (02:05)
user-ch  tty8         2018-06-02T13:59:14+0200 - 2018-06-02T14:12:41+0200  (00:13)
user30   tty7         2018-06-02T10:55:38+0200 - 2018-06-02T14:49:33+0200  (03:53)
user30   tty7         2018-06-02T09:30:32+0200 - 2018-06-02T10:55:33+0200  (01:25)'

  TMP_DB = 'test/tmp/test.yml'

  def test_that_it_has_a_version_number
    refute_nil ::Tyme::VERSION
  end

  def test_last_process
    res = {:user10=>{:"2018-06-02"=>33}, :user20=>{:"2018-06-02"=>841}, :user30=>{:"2018-06-02"=>1408}, :"user-ch"=>{:"2018-06-02"=>13}}
    last = Tyme::Last.new( StringIO.new(LAST_OUTPUT) )
    assert last.process == res
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
    manager = Tyme::Manager.new(TMP_DB, StringIO.new(LAST_OUTPUT))
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
end
