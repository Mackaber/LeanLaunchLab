CapistranoDbTasks
=================

Add database tasks to capistrano to a Rails project

Currently

* It only supports mysql (both side remote and local)
* Only synchronize remote to local (cap db:local:sync)

Commands mysql, mysqldump, bzip2 and unbzip2 must be in your PATH

Feel free to fork and to add more database support or new tasks.

Install
=======

Add it as a plugin
    ./script/plugin install git://github.com/sgruhier/capistrano-db-tasks.git

Add to config/deploy.rb:
    require 'vendor/plugins/capistrano-db-tasks/lib/dbtasks'
  
    # if you haven't already specified
    set :rails_env, "production"
  
    # if you want to remove the dump file after loading
    set :db_local_clean, true  

Example
=======

cap db:local:sync
or
cap production db:local:sync if you are using capistrano-ext to have multistages

Copyright (c) 2009 [Sébastien Gruhier - XILINUS], released under the MIT license
