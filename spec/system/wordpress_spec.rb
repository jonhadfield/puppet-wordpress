require 'spec_helper_system'

describe "setting up a wordpress instance" do
  it 'deploys a wordpress instance' do
    pp = %{
      class { 'apache': }
      class { 'apache::mod::php': }
      class { 'mysql::server': }
      class { 'mysql::bindings': php_enable => true, }
      host { 'wordpress.localdomain': ip => '127.0.0.1', }

      apache::vhost { 'wordpress.localdomain':
        docroot => '/opt/wordpress',
        port    => '80',
      }

      class { 'wordpress': }
    }

    puppet_apply(pp) do |r|
      expect([0,2]).to include(r.exit_code)
      expect(r.stderr).to eq("")
      r.refresh
      expect(r.exit_code).to be_zero
      expect(r.stderr).to eq("")
    end

    shell("/usr/bin/curl wordpress.localdomain:80/wp-admin/install.php") do |r|
      expect(r.exit_code).to be_zero
      expect(r.stdout).to match(/Install WordPress/)
    end
  end

  it 'deploys a wordpress instance as the httpd user with a secure DB password and a specific location' do
    pp = %{
      class { 'apache': }
      class { 'apache::mod::php': }
      class { 'mysql::server': }
      class { 'mysql::bindings::php': }

      apache::vhost { 'wordpress.localdomain':
        docroot => '/var/www/wordpress',
        port    => '80',
      }

      class { 'wordpress':
        install_dir => '/var/www/wordpress',
        wp_owner    => $apache::user,
        wp_group    => $apache::group,
        db_name     => 'wordpress',
        db_host     => 'localhost',
        db_user     => 'wordpress',
        db_password => 'hvyH(S%t(\"0\"16',
      }
    }

    pending
  end

  it 'deploys a wordpress instance with a remote DB'
  it 'deploys a wordpress instance with a pre-existing DB'
  it 'deploys a wordpress instance of a specific version'
  it 'deploys a wordpress instance from an internal server'
end
