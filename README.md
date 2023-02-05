# PoMaBuSe

Build Server? Build Agent! You need often ensure, your code compiles / tests on many different Linux flavors? But Bamboo is too expensive? Dr. Jekyll/Jenkins too complex to get started? Then you should ask Petty Officer Dr. Mabuse! *)

=Here we go!=

PoMaBuSe - "Poor Man's Build Server" is a set of Bash4 scripts and config files.
Very, very easy to configure, started on (1 or more) different linux machines (*ubuntu, debian, ...) as well as on MSYS2 (the bigger/better MinGW).

![Logo](./artwork_pomabuse_1.png?raw=true)


It polls your Version Control System for changes and if true, it compiles this code.
On failure, it f.i. reports by mail (any sendmail compatible mailer) all the developers which committed since the last successful build.

What to checkout, compile, report and how is defined in "job files". 
One can have many. 
SVN to mail address mapping is /etc/aliases or an own file.
SVN is, GIT comes, mail is, SIGNAL comes...

*) Dr. Mabuse: German novel figure, more straight than Dr.Jekyll & comparable powerful

## Features
build agent
build server
Linux
MSYS2 (Bash + MinGW)
