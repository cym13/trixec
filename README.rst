Description
===========

Trixec allows you to run conccurent tests in order to automate pentest tasks.
Of course while it was written as a security tool you may automate
everything using it : just define the tools you need.

Why ?
=====

Some missions are redundant and it helps to be certain that exactly the same
tests are run from one time to another while keeping a full log of the
activity.

Documentation
=============

Edit the first section of the script to change parameters. As it is meant to
be "configure once, run many times" it doesn't use command-line arguments.

Edit the second section to add tools. They must be named launch_<tool_name>
in order to be able to launch them using "launch <tool_name>" later. While
you could call your function directly the "launch" function provides a
wrapper managing output and status.

License
=======

This software is distributed under the terms of the WTFPL.

You should have received a copy of the WTFPL along with this progrum.
If not, see <http://www.wtfpl.net/txt/copying/>.

Contact
=======

::

    Main developper: Cédric Picard
    Email:           cedric.picard@efrei.net
