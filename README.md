# Ruby on Rails Tutorial sample application

## Reference implementation

This is the reference implementation of the sample application from 
[*Ruby on Rails Tutorial:
Learn Web Development with Rails*](https://www.railstutorial.org/)
(6th Edition)
by [Michael Hartl](http://www.michaelhartl.com/).

## License

All source code in the [Ruby on Rails Tutorial](https://www.railstutorial.org/)
is available jointly under the MIT License and the Beerware License. See
[LICENSE.md](LICENSE.md) for details.

## Getting started

To get started with the app, first clone the repo and `cd` into the directory:

```
$ git clone https://github.com/mhartl/sample_app_6th_ed.git 
$ cd sample_app_6th_ed
```

Then install the needed gems (while skipping any gems needed only in production):

```
$ bundle install --without production
```

Next, migrate the database:

```
$ rails db:migrate
```

Finally, run the test suite to verify that everything is working correctly:

```
$ rails test
```

If the test suite passes, you'll be ready to run the app in a local server:

```
$ rails server
```

## Branches

The reference app repository includes a separate branch for each chapter in the tutorial (Chapters 3–14). To examine the code as it appears at the end of a particular chapter, simply check out the corresponding branch using `git checkout`:

```
$ git checkout <branch name>
```

A full list of branch names appears as follows:

```
static-pages
rails-flavored-ruby
filling-in-layout
modeling-users
sign-up
basic-login
advanced-login
updating-users
account-activation
password-reset
user-microposts
following-users
```

Starting in Chapter 10 (“Updating users”), the sample app comes configured to seed the database with sample users, which you can activate by resetting the database and then running the seed program:

```
$ rails db:migrate:reset
$ rails db:seed
```

## Help with the Rails Tutoiral

Experience shows that comparing code with the reference app is often helpful for debugging errors and tracking down discrepancies. For additional assistance with any issues in the tutorial, please consult the [Rails Tutorial Help page](https://www.railstutorial.org/help). 

Suspected errors, typos, and bugs can be emailed to <admin@railstutorial.org>. All such reports are gratefully received, but please double-check with the [online version of the tutorial](https://www.railstutorial.org/book) and this reference app before submitting.
