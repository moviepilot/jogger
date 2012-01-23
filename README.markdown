# Jogger

Jogger is a JRuby library that enables lazy people to do very expressive graph traversals with the great [pacer gem](https://github.com/pangloss/pacer). If you don't know what the pacer gem is, you should probably not be here and check pacer out first.

# What does it do?

Jogger does two things:

1. Keep the current pacer traversal in an instance variable and allow for method chaining as well as changing the internal state of the traversal
2. Allows you to group together parts of a traversal (single pipes or groups of them) and give them a name. Named traversals. Helps to stay DRY.

The former is really just a syntax thing, whereas the latter can help you a great deal modeling semantics of your business logic as parts of traversals. These sentences confuse me, so I will give you examples.

# Example time!

## 1. Keep track of the current traversal

To demonstrate why point 1) in the list above can be useful, look at this traversal. It helps me find out what movies my female friends like the most, so I can impress them in a conversation:

    t = my_pacer_vertex.in(:friends)
    t = t.filter{ |v| v.properties['gender'] == 'female}
    t = t.out(:likes)
    t = t.filter{ |v| v.properties['type'] == 'Movie' }
    t = t.group_count{ |v| v }
    t = t.sort_by{ |v, c| -c }

Since I'm a very lazy person, I would prefer to write it a little shorter. Especially, since these multi step traversals are a pattern I found in our code at [moviepilot.com](http://moviepilot.com)) a lot.

So here's the Jogger way of expressing the same traversal:

    t = Jogger.new(my_pacer_vertex)
    t.in(:friends)
    t.filter{ |v| v.properties['gender'] == 'female' }
    t.out(:likes)
    t.filter{ |v| v.properties['type'] == 'Movie' }
    t.group_count{ |v| v }
    t.sort_by{ |v, c| -c }

See what I did there? Jogger keeps the current pacer traversal and forwards all method calls to that traversal, and then returns itself. So you could also write (in jogger as well as pacer):

       Jogger.new(my_pacer_node).in(:friends).filter{ … }.out(:likes).group_count{…}

Just saying, you can chain your methods, but I don't like it because I can only focus on 72 characters per line at max. If you want to access the current traversal, just call `result` on your Jogger instance.

## 2. Named traversals

So that traversal above, traversing from a node to all its friends, is pretty simple, but it could be simpler. Especially if it does things that you want to reuse in many other places. If you would explain the traveral to somebody, you'd say something along the lines of "The most popular movies amongst my friends, but only girls". How cool would it be if I just had to write this:

    t = Jogger.new(my_pacer_vertex)
    t.friends(:female)
    t.top_list(:movies)

No problem. Just define a few named traversals that do exactly this.

    class Jogger
      module NamedTraversals
        
        # Traverse to somebody's woman friends
        def self.friends(current_traversal, gender)
          t = current_traversal.in(:friends)
          t = t.filter{|v| v.properties['gender'] == gender}
        end
        
        # Group and sort
        def self.top_list(current_traversal, type)
          t = current_traversal.out(type)
          t = t.filter{ |v| v.properties['type'] == 'Movie' }
          t = t.group_count{ |v| v }
          t = t.sort_by{ |v, c| -c }
        end
      end
    end

These are silly examples, but if you look at your traversals I guarantee that you will find repeated patterns all over the place, and Jogger can help you stop repeating these and making the actual traversals much easier on the eyes.

# Installation

First, you need to load pacer and whatever graph db connector you need (we use pacer-neo4j, by the way) and define your named traversals as above. Jogger doesn't include these on purpose. Then, you have to:

    gem install pacer-jogger

and

    require 'jogger'

or if you're using bundler, add this to your Gemfile and bundle:

    gem "pacer-jogger", :require => "jogger"

That's it!
