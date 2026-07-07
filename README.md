# Maltese

Maltese is an opinionated package manager framework that keeps you in charge.  <br>
You provide Maltese with scripts for your dependencies, such as "brew install elixir", and Maltese packages them into a unified collection.

Maltese provides you with an idiomatic UI. You declare a dependency; title it --
and then provide a your setup scripts --as many as you want.

If need more time to set up your dependency scripts, Maltese lets you save your data and pick back up where you left off.

After you are done setting up your Maltese scripts, Maltese will produce a tarball with all of your scripts saved, along with an installer program.
You just provide your users with the tarball, and they will get walked through every dependency for your project.

# Quick explanation
Here's how Maltese will operate:

1 -> run Maltese <br>
2 -> create a package when prompted with options <br>
3 -> add dependencies to the package <br>
4 -> save your dependencies <br>
5 -> "compile" it <br>
6 -> Provide your users with the tarball <br>

# Users
on the user side of things:
Maltese walks down the list of your dependencies and brings up your chosen install scripts.
For each script, the user gets 3 options:
* Auto Install
* Manual Install
* Skip
The users can also choose to revisit skipped dependencies, if they change their mind. Upon doing so, they will be given the two install options (auto and manual).
