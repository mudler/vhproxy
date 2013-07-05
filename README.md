<i>VHProxy</i>
=======

This is a <i>Virtual Name Proxy </i>written in Perl using the Mojolicious Framework.

What it does
=======
Handles HTTP(S ?) request on a given port and forward each request to the host supplied.
Every request it's logged in the vhproxy.log file

Useful in a situation where you have 20 or 30 mojo (lite, i hope) apps running in more VMs or ports where you couldn't use lighttpd,apache, nginx...
You just set up your dns to your proxy(s) and you are ready to go.
Personally i use this software on the same machine and on a totally private network (think a little bit at security :) )

Installation
=======

 - First install cpanm. ```cpan App::cpanminus```
 - Clone the repository and run ```cpanm --installdeps .```
 - You are done.

    
Configuration
=======

VHProxy will look for configuration files in <i>$HOME/.vhproxy</i>, <i>/etc/vhproxy</i> and under <i>config/</i> in the same path of the program.
Every path can have other subs, so you can have more configuration files located on more directories.

Configuration files are in <i>YAML</i>, there is a self-explanatory example file under <i>config/</i>


Usage
=======

Just run it with morbo or hypnotoad.
``` hypnotoad vhproxy````

use morbo to see what happens.


About
=======

It's not intended to be a big software, i just use it in my own small (dev) environments to setup a proxy whenever i need to
(leveraging Mojo Hypnotoad fork capabilities) don't be afraid to open an issue or contact me by email.
