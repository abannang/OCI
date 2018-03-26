import sys
import MySQLdb
import memcache

memc = memcache.Client(['10.0.2.1:11211'], debug=1);

try:
    conn = MySQLdb.connect (host = "10.0.3.2",
                            user = "sakila",
                            passwd = "password",
                            db = "sakila")
except MySQLdb.Error, e:
     print "Error %d: %s" % (e.args[0], e.args[1])
     sys.exit (1)

print "Success! Connected to Memcached instances and MySQL DB."