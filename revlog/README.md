# octopus::Revlog

**Assumptions:**

- The user will not look inside `file_id` objects (I mean they *can*, it's just pretty gnarly in there)
- Only one `Revlog` is operating at one time (pretty much a singleton)


### Revlog
Everything is contained within the `revlog.rb` file.

`Revlog` is an entirely static class. That is, it **cannot be instantiated**. All methods are class level (using a *metaclass*!) and called by `Revlog::method`. Originally there were instances of `Revlog` but it was changed as the group felt more than one `Revlog` was unnecessary.

It operates with a class instance variable `file_table` which stores files and their contents while `Revlog` is active in memory, and uses loads/writes to maintain `file_table` as a file, `revlog.json`, when not active.

Everything related to the methods of `Revlog` should be contained as Javadoc style comments within `revlog.rb`.

One edit I would make for increased readibility/modularity is for the method `merge`. Currently this is a monster of a method, though most functionality is modularized through lambda functions. The change I would make would be to pull these lambda functions out into their own nested methods inside `merge`, passing the current state through use of an object. Unfortunately, functional improvement work took priority over this stylistic improvement.

Additionally, I might look deeper into the singleton vs static class trade-offs and turn `Revlog` singleton if it seemed superior.


----------



_M_**a**r*k*d*o*w**n** is **fun**_!_
> _M_**a**r*k*d*o*w**n**

![If you see this it's bad](https://octodex.github.com/images/strongbadtocat.png)