require 'active_record'
require 'salebot_uploader/orm/activerecord'
Bundler.require

ActiveRecord::Base.establish_connection({ adapter: 'sqlite3', database: ':memory:' })

ActiveRecord::Migration.verbose = false
