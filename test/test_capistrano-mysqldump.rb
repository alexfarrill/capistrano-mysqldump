require 'helper'


class TestCapistranoMysqldump < Test::Unit::TestCase
  mysqldump = Capistrano::Mysqldump

  context '.options_string' do
    should "not include falesy values" do
      assert_equal '', mysqldump.options_string({:a => nil, :b => false})
    end

    should 'use "--" prefix and "=" join for length > 1 keys' do
      assert_equal '--multi_char_key=foo', mysqldump.options_string(:multi_char_key => 'foo')
    end

    should 'use "-" prefix and "" join for length == 1 keys' do
      assert_equal '-ofoo', mysqldump.options_string({:o => 'foo'})
    end
    
    should 'not include variable for value = true' do
      assert_equal '-o --multi_char_key', mysqldump.options_string(:o => true, :multi_char_key => true)
    end
  end

  context '.credential_options(username, password)' do
    should 'includes password if it exists' do
      assert_equal(
        {:u => 'foo', :p => 'bar'}, 
        mysqldump.credential_options('foo', 'bar')
      )
    end

    should 'does not include password if falsey or empty' do
      assert_equal(
        {:u => 'foo'},
        mysqldump.credential_options('foo', ''), 
        mysqldump.credential_options('foo', false)
      )
    end
  end
end
