# Installing Mailman 3 under Debian 8

March 9, 2017.

We'll use Vagrant:

    $ cat Vagrantfile
    Vagrant.configure(2) do |config|
      config.vm.box = "debian/jessie64"
      config.vm.provider "virtualbox" do |vb|
         vb.memory = "2048"  # Ran into some trouble with only 1GB of RAM
       end
    end

    $ vagrant up
    $ vagrant ssh


Everything following is in the VM.

    $ lsb_release -a
    No LSB modules are available.
    Distributor ID: Debian
    Description:    Debian GNU/Linux 8.7 (jessie)
    Release:        8.7
    Codename:       jessie

Let's go install some packages:

    $ sudo apt-get install python-pip python3-pip python-dev sqlite3 libsqlite3-dev postfix ruby-sass vim git  curl nginx

For postfix installation need to choose the "General type of mail configuration." Went for option "Internet Site," and host name mail.vanlu.ga.

One more package

    $ sudo pip install virtualenv

By the way, these are our python versions.

    $ pip --version
    pip 1.5.6 from /usr/lib/python2.7/dist-packages (python 2.7)
    $ python2 --version
    Python 2.7.9
    $ python3 --version
    Python 3.4.2

Now add a user for the various Mailman 3 packages.

    $ sudo adduser mm3 # enter password etc.
    $ su mm3
    $ cd
    $ pwd
    /home/mm3

Ok, time to go get the Mailman code.

First, define a bash function to help document our git HEAD's as we go along:

    $ function whats-git-head {
      b=$(git branch 2>/dev/null|grep '^*' | colrm 1 2)
      echo "Branch is $b"
      git log --date=iso --pretty=format:'HEAD of BRANCHSUBS is %h, %aN, %<(19,trunc)%ad, %<(120,trunc)%s' $* | head -1 | sed -e "s/BRANCHSUBS/$b/"
     }

    $ git clone https://gitlab.com/mailman/mailman.git
    $ cd mailman
    $ whats-git-head 
    Branch is master
    HEAD of master is 9753361, Barry Warsaw, 2017-02-21 15:00:.., Merge branch 'diffcov' into 'master'    

Set up python virtualenv's:

    $ virtualenv -p /usr/bin/python2 env2
    $ virtualenv -p /usr/bin/python3 env # no 3 at end

Check out these virtualenvs:

    $ bash # New shell
    $ source env2/bin/activate
    (env2) mm3@jessie:~/mailman$ python --version
    Python 2.7.9
    $ exit

    $ bash
    $ source env/bin/activate
    (env) mm3@jessie:~/mailman$ python --version
    Python 3.4.2

Python 3 is the one to use for the "main" mailman installation

    (env) mm3@jessie:~/mailman$ python setup.py develop
    (env) mm3@jessie:~/mailman$ exit

Install mailmanclient.

    $ pwd
    /home/mm3/mailman
    $ git clone https://gitlab.com/mailman/mailmanclient.git 
    $ cd mailmanclient
    $ whats-git-head 
    Branch is master
    HEAD of master is 15195ac, 2017-02-03, Barry Warsaw, Merge branch 'news' into 'master'                                                                                       
    $ cd ~/mailman
    $ source env2/bin/activate
    (env2) mm3@jessie:~/mailman$ cd mailmanclient/
    (env2) mm3@jessie:~/mailman/mailmanclient$ python setup.py develop

(All else will be using Python 2, so we'll stay in "env2")

Install django-mailman3.

    (env2) mm3@jessie:~/mailman/mailmanclient$ cd ~/mailman
    (env2) mm3@jessie:~/mailman$ git clone https://gitlab.com/mailman/django-mailman3.git
    (env2) mm3@jessie:~/mailman$ cd django-mailman3
    (env2) mm3@jessie:~/mailman/django-mailman3$ whats-git-head 
    Branch is master
    HEAD of master is 60f551c, Aurélien Bompard, 2017-02-02 11:32:.., Make sure the middleware tests pass even with custom config 

Before running setup.py, install this version of django. Version 1.10 causes trouble!

    (env2) mm3@jessie:~/mailman/django-mailman3$ pip install django==1.9
    (env2) mm3@jessie:~/mailman/django-mailman3$ python setup.py develop

Install postorius.

    (env2) mm3@jessie:~/mailman/django-mailman3$ cd ~/mailman
    (env2) mm3@jessie:~/mailman$ git clone https://gitlab.com/mailman/postorius.git
    (env2) mm3@jessie:~/mailman/$ cd postorius
    (env2) mm3@jessie:~/mailman/postorius$ whats-git-head 
    Branch is master
    HEAD of master is 6ffddf5, Florian Fuchs, 2017-02-18 06:54:.., Merge branch '3.1' into 'master'                                                                                        
    (env2) mm3@jessie:~/mailman/django-mailman3$ python setup.py develop

Install hyperkitty.

    (env2) mm3@jessie:~/mailman/django-mailman3$ cd ~/mailman
    (env2) mm3@jessie:~/mailman/django-mailman3$ git clone https://gitlab.com/mailman/hyperkitty.git
    (env2) mm3@jessie:~/mailman/django-mailman3$ cd hyperkitty
    (env2) mm3@jessie:~/mailman/hyperkitty$ whats-git-head 
    Branch is master
    HEAD of master is 45f6e70, Aurélien Bompard, 2017-02-10 15:58:.., Fix typo
    (env2) mm3@jessie:~/mailman/hyperkitty$ pip install rcssmin  
    (env2) mm3@jessie:~/mailman/hyperkitty$ python setup.py develop

Install mailman-hyperkitty, using Python 3!

    $ cd ~/mailman
    $ source env/bin/activate
    (env3) mm3@jessie:~/mailman/$ git clone https://github.com/hyperkitty/mailman-hyperkitty.git
    (env3) mm3@jessie:~/mailman$ cd mailman-hyperkitty/
    (env3) mm3@jessie:~/mailman/mailman-hyperkitty$ whats-git-head 
    Branch is master
    HEAD of master is 10da29c, Aurélien Bompard, 2015-04-29 11:54:.., Version 1.0.0                                                                 
    (env) mm3@jessie:~/mailman/mailman-hyperkitty$ python setup.py develop

Now we have downloaded all that we need. Next is configuration.

    $ cd ~/mailman
    mm3@jessie:~/mailman$ source env/bin/activate # Need Python 3
    (env) mm3@jessie:~/mailman$ mkdir dev-root
    (env) mm3@jessie:~/mailman$ cd dev-root
    (env) mm3@jessie:~/mailman$ mailman start

Change file var/etc/mailman.cfg; no leading slash; this is still in the dev-root directory!

    (env) mm3@jessie:~/mailman$ cat > var/etc/mailman.cfg << END_MAILMAN_CFG
    [devmode]
    enabled: no
    recipient: your.address@your.domain
    [mta]
    incoming: mailman.mta.postfix.LMTP
    outgoing: mailman.mta.deliver.deliver
    lmtp_host: 127.0.0.1
    lmtp_port: 8024
    smtp_host: localhost
    smtp_port: 25
    configuration: python:mailman.config.postfix
    END_MAILMAN_CFG

Then kill the mailman process, and restart

    (env) mm3@jessie:~/mailman$ mailman stop
    Shutting down Mailman's master runner
    (env) mm3@jessie:~/mailman/dev-root$ mailman start
    Starting Mailman's master runner

From now using Python 2 again.

    (env) mm3@jessie:~/mailman/dev-root$ exit  # New shell
    $ cd ~/mailman
    $ source env2/bin/activate
    (env2) mm3@jessie:~/mailman$ cd postorius
    (env2) mm3@jessie:~/mailman$ cp -r example_project vanluga

In file vanluga/settings.py change
1. SECRET_KEY
2. ALLOWED_HOSTS = \['*', 'mail.vanlu.ga'\]

    (env2) mm3@jessie:~/mailman$ python vanluga/manage.py  migrate
    (env2) mm3@jessie:~/mailman$ python vanluga/manage.py  createsuperuser

Fill Username, password and email as desired. You will need to follow a verification link that is sent to the email; so better use one that works. Then it will say:
    Superuser created successfully.

Side topic; configuration of postfix (taken from http://thinlight.org/2012/03/10/postfix-only-allow-whitelisted-recipient-domains/). For development/test rides, find it convenient to use mailinator.com addresses but want to avoid sending emails to any other domain (bugs/misconfiguration/etc). Put this in /etc/postfix/recipient_domains:

    mailinator.com OK
    mail.vanlu.ga OK

This in /etc/postfix/main.cf,

    smtpd_recipient_restrictions = check_recipient_access hash:/etc/postfix/recipient_domains, reject

Run as root:

    $ postmap /etc/postfix/recipient_domains
    $ service postfix restart

End side topic. Back to running postorius.

    (env2) mm3@jessie:~/mailman$ django-admin runserver 0.0.0.0:8000 --pythonpath vanluga --settings settings

In a browser, go to http://127.0.0.1:8000/admin/. Login as admin or whatever set up with the createsuperuser command above.

* Go to http://127.0.0.1:8000/admin/sites/site/add.
* Enter Domain Name and Display Name as mail.vanlu.ga.
* Click Save button

* Go to http://127.0.0.1:8000/admin/django_mailman3/maildomain/add/.
* Select Site as mail.vanlu.ga Enter Mail Domain mail.vanlu.ga.
* Click Save

* Go to http://127.0.0.1:8000/postorius/lists/.
* Click green button "Create new domain" (URL postorius/domains/new/)
* Enter mail.vanlu.ga in all three fields, Mail Host, Description and Web Host.
* Click the Create Domain button

* Go back to http://127.0.0.1:8000/postorius/lists/
* Click the button Create New List
* Enter List Name news
* Mail Host mail.vanlu.ga
* Description Testing
* Check off Advertise this list in list index  
* Click the Create List button

Add at end of file /etc/postfix/main.cf

    transport_maps       = hash:/home/mm3/mailman/dev-root/var/data/postfix_lmtp 
    local_recipient_maps = hash:/home/mm3/mailman/dev-root/var/data/postfix_lmtp
    relay_domains        = hash:/home/mm3/mailman/dev-root/var/data/postfix_domains

Run command, as root:

    $ service postfix restart

    $ cd ~/mailman
    $ source env2/bin/activate
    (env2) mm3@jessie:~/mailman$ cd hyperkitty
    (env2) mm3@jessie:~/mailman/hyperkitty$ cp -r example_project vanluga

Set in file vanluga/settings.py: 

1. SECRET_KEY = 'mm3-mailman-hyperkitty-123'
2. ALLOWED_HOSTS:   "mail.vanlu.ga"
3. MAILMAN_ARCHIVER_KEY:   "MMMSecretArchiverAPIKey"
4. Change sassc to sass in the COMPRESS_PRECOMPILERS section (2 lines)

    (env2) mm3@jessie:~/mailman/hyperkitty$ django-admin migrate --pythonpath vanluga --settings settings
    (env2) mm3@jessie:~/mailman/hyperkitty$ pip install whoosh
    (env2) mm3@jessie:~/mailman/hyperkitty$ python vanluga/manage.py collectstatic # Answer yes when prompted

Run as root, presumably:

    $ chown -R  mm3:www-data /home/mm3/mailman/hyperkitty/vanluga/static/CACHE
    $ chown -R  mm3:www-data /home/mm3/mailman/hyperkitty/vanluga/static/hyperkitty

    (env) mm3@jessie:~/mailman/$ cd ~/mailman/mailman-hyperkitty
    (env) mm3@jessie:~/mailman/mailman-hyperkitty$ cat > mailman-hyperkitty.cfg <<END_HYPERKITTY_CFG
    [general]
    base_url: http://localhost:8002/hyperkitty/
    api_key: MMMSecretArchiverAPIKey
    END_HYPERKITTY_CFG

And add to file ~/mailman/dev-root/var/etc/mailman.cfg :

    [archiver.hyperkitty]
    class: mailman_hyperkitty.Archiver
    enable: yes
    configuration: /home/mm3/mailman/mailman-hyperkitty/mailman-hyperkitty.cfg

Restart mailman, see above.

Run hyperkitty server.

    $ cd ~/mailman
    $ source env2/bin/activate
    (env2) mm3@jessie:~/mailman/hyperkitty$ cd hyperkitty
    (env2) mm3@jessie:~/mailman/hyperkitty$ django-admin runserver 0.0.0.0:8002 --pythonpath vanluga --settings settings

Need to add crontab entries (based on ~/mailman/hyperkitty/vanluga/crontab)

    $ cat > vanluga/crontab <<END_CRONTAB
    MAILTO=""
    * * * * * cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs minutely --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    2,17,32,47 * * * * cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs quarter_hourly --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    @hourly cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs hourly --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    @daily cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs daily --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    @weekly cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs weekly --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    @monthly cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs monthly --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    @yearly cd /home/mm3/mailman/hyperkitty && /home/mm3/mailman/env2/bin/python /home/mm3/mailman/env2/bin/django-admin.py runjobs yearly --pythonpath /home/mm3/mailman/hyperkitty/vanluga --settings settings
    END_CRONTAB
    $ crontab vanluga/crontab


Put in nginx.conf:

    user www-data;
    worker_processes 4;
    pid /run/nginx.pid;
    events {
            worker_connections 768;
    }
    http {
            sendfile on;
            tcp_nopush on;
            tcp_nodelay on;
            keepalive_timeout 65;
            types_hash_max_size 2048;
            include /etc/nginx/mime.types;
            default_type application/octet-stream;
            ssl_prefer_server_ciphers on;
            access_log /var/log/nginx/access.log;
            error_log /var/log/nginx/error.log;
            gzip on;
            gzip_disable "msie6";
      server {
        server_name localhost mail.vanlu.ga;
        listen 100;
        location /static/CACHE {
            alias /home/mm3/mailman/hyperkitty/vanluga/static/CACHE;
            expires max;
            access_log off;
        }
        location /static/hyperkitty {
            alias /home/mm3/mailman/hyperkitty/vanluga/static/hyperkitty;
            expires max;
            access_log off;
        }
        location /hyperkitty {
          proxy_set_header X-Real-IP $remote_addr;
          proxy_pass http://localhost:8002/hyperkitty;
        }
        location / {
          proxy_set_header X-Real-IP $remote_addr;
          proxy_pass http://localhost:8000;
        }
      }
    }
