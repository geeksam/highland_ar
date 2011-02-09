module HighlandAR
  module ClassMethods
    # There are no options. THERE CAN BE ONLY ONE!
    def there_can_be_only_one(association_name)
      # puts "There can be only one #{association_name} in #{self}!"
      has_one association_name
      define_tcboo_setter(association_name)
    end
    
    protected
    def define_tcboo_setter(association_name)
      define_method "#{association_name}_with_immortal_combat=" do |*combatants|
        champion = tcboo_tournament(combatants.flatten) # Gimme gimme gimme FRIED CHICKEN!
        self.send(:"#{association_name}_without_immortal_combat=", champion)
      end
      alias_method_chain :"#{association_name}=", :immortal_combat
    end
  end
  
  module InstanceMethods
    # The "tcboo_" prefix is there in case of namespacing conflicts. As if anyone was going to use this.

    protected
    def tcboo_power_for(combatant)
      @power_rankings ||= {}
      @power_rankings[combatant] ||= (1 + rand(10))
    end
    def tcboo_set_power_for(combatant, new_power)
      @power_rankings[combatant] = new_power
    end
    
    def tcboo_tournament(combatants)
      @power_rankings = {} # Start each tournament with a level playing field.  Also:  thread safety?  In a joke plugin?  Um... no.

      round = 0
      while combatants.length > 1
        current_round_winners = []
        puts "--- ROUND #{round+=1} ---" if $debug
        tcboo_shuffle_combatants(combatants).each_slice(2) do |a, b|
          current_round_winners << tcboo_immortal_combat(a, b)
        end
        combatants = current_round_winners
      end

      combatants.first
    end

    # Shuffle the array to avoid being unfair to the Nth combatant in a list of N combatants where N is odd.
    # Do it in a separate function for mockability.
    def tcboo_shuffle_combatants(combatants)
      combatants.shuffle
    end

    # Two men enter! One man leaves!
    # ...oops, sorry, wrong franchise.
    def tcboo_immortal_combat(a, b)
      ap, bp = tcboo_power_for(a), tcboo_power_for(b)

      if b.nil?
        puts "#{a} (#{ap}) wins this match by virtue of being the odd entity out" if $debug
        return a
      end

      total_power = ap + bp
      winner = (rand(1 + total_power) <= ap) ? a : b
      loser  = (winner == a ? b : a)
      tcboo_set_power_for winner, total_power
      tcboo_set_power_for loser, 0
      puts "In a fight between #{a} (#{ap}) and #{b} (#{bp}), who would win? #{winner} (#{total_power})!" if $debug
      winner
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
