# Jogger - almost like named scopes

Jogger is a JRuby library that enables lazy people to do very expressive graph traversals with the great [pacer gem](https://github.com/pangloss/pacer). If you don't know what the pacer gem is, you should probably not be here and check pacer out first.

# What does Jogger do? TL;DR

Remember the _named scopes_ from back in the days when you were using rails? Jogger gives you _named traversals_ and is a little bit like named scopes. Jogger groups multiple pacer traversals together and give them a name. Pacer traversals are are like pipes. What are pipes? [Pipes are great!](http://markorodriguez.com/2011/08/03/on-the-nature-of-pipes/)!

The most important conceptual difference is, that the order in which named traversals are called matter, while it usually doesn't matter in which order you call named scopes.

# Jogger does two things:

1. Keep the current pacer traversal in an instance variable and allow for method chaining as well as changing the internal state of the traversal
2. Allows you to group together parts of a traversal (single pipes or groups of them) and give them a name. Named traversals. Helps to stay DRY.

The former is really just a syntax thing, whereas the latter can help you a great deal modeling semantics of your business logic as parts of traversals. These sentences confuse me, so I will give you a TL;DR gif followed by some hands on examples.

![Run](http://dl.dropbox.com/u/1953503/gifs/vizPZ.gif)


# Feature #1: keep the current traversal

To demonstrate why point 1) in the list above can be useful, look at this traversal. It helps me find out what movies my female friends like the most, so I can impress them in a conversation:

    t = my_pacer_vertex.in(:friends)
    t = t.filter(gender: 'female')
    t = t.out(:likes)
    t = t.filter(type: 'Movie')
    t = t.sort_by{ |v, c| -c }
    t = t.group_count{ |v| v }

Since I'm a very lazy person, I would prefer to write it a little shorter. Especially, since these multi step traversals are a pattern I found in our code at [moviepilot.com](http://moviepilot.com)) a lot.

So here's the Jogger way of expressing this:

    t = Jogger.new(my_pacer_vertex)
    t.in(:friends)
    t.filter(gender: 'female')
    t.out(:likes)
    t.filter(type: 'Movie')
    t.sort_by{ |v, c| -c }
    t.group_count{ |v| v }

See what I did there? Jogger keeps the current pacer traversal and forwards all method calls to that traversal, and then returns itself. So you could also write (in jogger as well as pacer):

       Jogger.new(my_pacer_node).in(:friends).filter(…).out(:likes).group_count{…}

Just saying, you can chain your methods, but I don't like it cause I can only focus on 72 characters per line at max. If you want the current traversal, just call `result` on your Jogger instance.

## Feature #2: Named Traversals

So that traversal above, traversing from a node to all its friends, is pretty simple, but it could be simpler. Especially if it does things that you want to reuse in many other places. How cool would it be if I just had to write this:

    t = Jogger.new(my_pacer_vertex)
    t.friends(:female)
    t.top_list(:movies)

No problem. Just define named traversals that aggregate different pipes and give them a name:

    class Jogger
      module NamedTraversals
        
        # Traverse to somebody's woman friends
        def self.friends(current_traversal, gender)
          t = current_traversal.in(:friends)
          t = t.filter(gender: gender)
        end

        # Group and sort
        def self.top_list(current_traversal, type)
          t = current_traversal.out(type)
          t = t.filter(type: 'Movie')
          t = t.group_count{ |v| v }
        end
      end
    end

These are silly examples, but if you look at your traversals I guarantee that you will find repeated patterns all over the place, and Jogger can help you stop repeating these and making the actual traversals much easier on the eyes.

# Installation

First, you need to load pacer and whatever graph db connector you need (we use neo4j, by the way) and define your named traversals as above. Jogger doesn't include these on purpose. Then, you have to 

    gem install pacer-jogger

and 

    require 'jogger'

or for your Gemfile

    gem "pacer-jogger", :require => "jogger"

That's it!

# Documentation

I gave YARD a shot, so to open the documentation in your browser just do this in the jogger directory:

    yard server & sleep 3 && open http://localhost:8808/docs/file/README.markdown

Or you can (browse the documentation online)[http://rubydoc.info/github/jayniz/jogger/master/frames]

# Named traversals - The pacer way

You can implement feature #2 purely in pacer, if you like. For example, you could express

    my_node.out.filter(type: 'Movie')

with

    my_node.out(Movie)

For this to work you need to tell pacer, what `Movie` actually means. In the simplest form, you could say:

    module Movie
      def self.route_conditions
        { type: 'Movie' }
      end
    end
    
That way pacer knows, whenever you're talking about a `Movie` you want to filter those elements whose `type==Movie`. To do something like the named traversals described above, you could go ahead and define a route to all female likers of a movie:
     
    module Girl
      def self.route_conditions
        {gender: :female}
      end
    end
    
    module Movie
      def self.route_conditions
        { type: 'Movie' }
      end

    
      module Route
        def female_likers
          self.in_e(:likes).in_v(Girl)
        end
      end
    end

You can then go ahead and fetch:

    t.out(Movie).female_likers

To wrap it up, using Jogger to do named traversals is for the super lazy. If you use pacer exclusively and have more complicated structures it would probably make more sense to create your named traversals in the design of your domain logic and do it purely with pacer. You can still use Jogger to traverse these routes. If you want to share common traversal patterns between different models it might be easier to do with Jogger.
