require File.join(File.dirname(__FILE__), *%w[test_helper])

class HighlandARModuleTest < HighlandARTestCase
  test "module is loadable" do
    assert_nothing_raised(NameError) { HighlandAR }
    assert_kind_of(Module, HighlandAR)
  end

  test "module gives includers a .there_can_be_only_one macro" do
    Platypus = new_highlandar_class
    assert_nothing_raised(NoMethodError) { Platypus.there_can_be_only_one :bill }
  end

  test "calling the macro invokes .has_one" do
    Alpaca = new_highlandar_class
    Alpaca.expects(:has_one).with(:spitoon)
    Alpaca.stubs(:define_tcboo_setter)
    Alpaca.there_can_be_only_one :spitoon
  end

  test "calling the macro invokes .define_tcboo_setter" do
    Chimera = new_highlandar_class
    Chimera.expects(:define_tcboo_setter).with(:snake_head)
    Chimera.there_can_be_only_one :snake_head
  end

  test ".define_tcboo_setter does what it says" do
    Chinchilla = new_highlandar_class
    Chinchilla.there_can_be_only_one :cute_little_dust_bath_basin

    assert Chinchilla.instance_methods.include?('cute_little_dust_bath_basin='), 'wanted setter'
    assert Chinchilla.instance_methods.include?('cute_little_dust_bath_basin_without_immortal_combat='), 'wanted old setter too'
  end
end

class TCBOO_SetterTest < HighlandARTestCase
  class Arena < NotActuallyActiveRecordBase
    include HighlandAR
    there_can_be_only_one :champion
  end

  def setup
    @arena = Arena.new
  end

  test "single contestant is automatically selected -- argument as object" do
    @arena.expects(:tcboo_immortal_combat).never
    @arena.champion = 'Frodo'
    assert_equal('Frodo', @arena.champion)
  end

  test "single contestant is automatically selected -- argument as array" do
    @arena.expects(:tcboo_immortal_combat).never
    @arena.champion = %w[Frodo]
    assert_equal('Frodo', @arena.champion)
  end

  test "champion selection functions as a playoff tree, two entrants" do
    @arena.expects(:tcboo_shuffle_combatants).with(%w[Frodo Gimli]).returns(%w[Frodo Gimli])
    @arena.expects(:tcboo_immortal_combat).with('Frodo', 'Gimli').returns('Gimli')
    @arena.champion = %w[Frodo Gimli]
    assert_equal('Gimli', @arena.champion)
  end

  test "champion selection functions as a playoff tree, three entrants" do
    # Round 1
    @arena.expects(:tcboo_shuffle_combatants).with(%w[Frodo Gimli Elrond]).returns(%w[Frodo Gimli Elrond])
    @arena.expects(:tcboo_immortal_combat).with('Frodo', 'Gimli').returns('Gimli')
    @arena.expects(:tcboo_immortal_combat).with('Elrond', nil).returns('Elrond')

    # Round 2
    @arena.expects(:tcboo_shuffle_combatants).with(%w[Gimli Elrond]).returns(%w[Gimli Elrond])
    @arena.expects(:tcboo_immortal_combat).with('Gimli', 'Elrond').returns('Gimli')

    @arena.champion = %w[Frodo Gimli Elrond]
    assert_equal('Gimli', @arena.champion)
  end

  test "champion selection functions as a playoff tree, four entrants" do
    # Round 1
    @arena.expects(:tcboo_shuffle_combatants).with(%w[Frodo Gimli Elrond Luke]).returns(%w[Frodo Gimli Elrond Luke])
    @arena.expects(:tcboo_immortal_combat).with('Frodo', 'Gimli').returns('Frodo')
    @arena.expects(:tcboo_immortal_combat).with('Elrond', 'Luke').returns('Gandalf')  # just making sure you're paying attention

    # Round 2
    @arena.expects(:tcboo_shuffle_combatants).with(%w[Frodo Gandalf]).returns(%w[Frodo Gandalf])
    @arena.expects(:tcboo_immortal_combat).with('Frodo', 'Gandalf').returns('Gandalf') # obviously

    @arena.champion = %w[Frodo Gimli Elrond Luke]
    assert_equal('Gandalf', @arena.champion)
  end

  test "champion selection functions as a playoff tree, nine entrants" do
    # Round 1
    @arena.expects(:tcboo_shuffle_combatants).with(%w[A B C D E F G H I]).returns(%w[A B C D E F G H I])
    @arena.expects(:tcboo_immortal_combat).with('A', 'B').returns('A')
    @arena.expects(:tcboo_immortal_combat).with('C', 'D').returns('C')
    @arena.expects(:tcboo_immortal_combat).with('E', 'F').returns('E')
    @arena.expects(:tcboo_immortal_combat).with('G', 'H').returns('G')
    @arena.expects(:tcboo_immortal_combat).with('I', nil).returns('I')

    # Round 2
    @arena.expects(:tcboo_shuffle_combatants).with(%w[A C E G I]).returns(%w[A C E G I])
    @arena.expects(:tcboo_immortal_combat).with('A', 'C').returns('C')
    @arena.expects(:tcboo_immortal_combat).with('E', 'G').returns('G')
    @arena.expects(:tcboo_immortal_combat).with('I', nil).returns('I')  # CGI. Get it? CGI! ... sheesh. tough room.

    # Round 3
    @arena.expects(:tcboo_shuffle_combatants).with(%w[C G I]).returns(%w[C G I])
    @arena.expects(:tcboo_immortal_combat).with('C', 'G').returns('G')
    @arena.expects(:tcboo_immortal_combat).with('I', nil).returns('I')  # Knowing is half the battle.

    # Round 4
    @arena.expects(:tcboo_shuffle_combatants).with(%w[G I]).returns(%w[G I])
    @arena.expects(:tcboo_immortal_combat).with('G', 'I').returns('I')  # Co-champions: 'Me', 'Myself'.

    @arena.champion = %w[A B C D E F G H I]
    assert_equal('I', @arena.champion)
  end

  test "this 'test' (a) is random and (b) has no assertions; I include it solely for the amusing side effects" do
    begin
      puts ''
      $debug = true
      @arena.champion = %w[Luke Elrond Gandalf Obi-Wan Magneto Ganondorf RandomBystander Tweedledee Alice]
    ensure
      $debug = false
    end
  end
end

class TmbgReferenceTest < HighlandARTestCase
  class Fight < NotActuallyActiveRecordBase
    include HighlandAR
    there_can_be_only_one :winner
  end

  class Man < NotActuallyActiveRecordBase
    def initialize(attrs = {})
      @name = attrs[:name]
    end
    def inspect
      "<#{@name}>"
    end
  end

  class ::String
    def Man
      TmbgReferenceTest::Man.new(:name => titlecase + ' Man')
    end
  end

  test "the example from the README" do
    particle_man = "Particle".Man  # Doin' the things a particle can
    triangle_man = "Triangle".Man  # Triangle man hates Particle Man
    person_man   = "Person".Man    # Hit on the head with a frying pan

    Fight.new.tap do |fight|
      fight.expects(:tcboo_shuffle_combatants).with([triangle_man, particle_man]).returns([triangle_man, particle_man])
      fight.expects(:tcboo_immortal_combat).with(triangle_man, particle_man).returns(triangle_man)
      fight.winner = [triangle_man, particle_man]
      assert_equal triangle_man, fight.winner
    end

    Fight.new.tap do |fight|
      fight.expects(:tcboo_shuffle_combatants).with([triangle_man, person_man]).returns([triangle_man, person_man])
      fight.expects(:tcboo_immortal_combat).with(triangle_man, person_man).returns(triangle_man)
      fight.winner = [triangle_man, person_man]
      assert_equal triangle_man, fight.winner
    end
  end
end

