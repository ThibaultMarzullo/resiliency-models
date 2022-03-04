# insert your copyright here

# see the URL below for information on how to write OpenStudio measures
# http://nrel.github.io/OpenStudio-user-documentation/reference/measure_writing_guide/

# start the measure
class AddBatteriesAndPV < OpenStudio::Measure::EnergyPlusMeasure
  # human readable name
  def name
    # Measure name should be the title case of the class name.
    return 'Add Batteries and PV'
  end

  # human readable description
  def description
    return 'Add batteries and PV generation to baseline building.  Add relevant controls.'
  end

  # human readable description of modeling approach
  def modeler_description
    return 'In an all-electric building, include on-site storage and generation for improved building resiliency.'
  end

  # define the arguments that the user will input
  def arguments(workspace)
    args = OpenStudio::Measure::OSArgumentVector.new

    # the name of the zone to add to the model
    batt_storage_capacity = OpenStudio::Measure::OSArgument.makeDoubleArgument('batt_storage_capacity', true)
    batt_storage_capacity.setDisplayName('Capacity of the battery bank')
    batt_storage_capacity.setDescription('Total capacity of the battery bank in Joules (J)')
    args << batt_storage_capacity

    batt_discharge_power = OpenStudio::Measure::OSArgument.makeDoubleArgument('batt_discharge_power', true)
    batt_discharge_power.setDisplayName('Battery discharge power')
    batt_discharge_power.setDescription('Maximum discharge power in Watts (W)')
    args << batt_discharge_power

    batt_charge_power = OpenStudio::Measure::OSArgument.makeDoubleArgument('batt_charge_power', true)
    batt_charge_power.setDisplayName('Battery charge power')
    batt_charge_power.setDescription('Maximum charge power in Watts (W)')
    args << batt_charge_power

    batt_initial_charge = OpenStudio::Measure::OSArgument.makeDoubleArgument('batt_initial_charge', true)
    batt_initial_charge.setDisplayName('Initial battery charge')
    batt_initial_charge.setDescription('Initial charge of the battery bank in Joules (J)')
    args << batt_initial_charge

    pv_total_power = OpenStudio::Measure::OSArgument.makeDoubleArgument('pv_total_power', true)
    pv_total_power.setDisplayName('Total PV power')
    pv_total_power.setDescription('Total power output of the PV panels in Watts (W)')
    args << pv_total_power

    parallel_modules = OpenStudio::Measure::OSArgument.makeIntegerArgument('parallel_modules', true)
    parallel_modules.setDisplayName('Number of PV modules in a series string')
    parallel_modules.setDescription('Number of modules')
    args << parallel_modules

    series_modules = OpenStudio::Measure::OSArgument.makeIntegerArgument('series_modules', true)
    series_modules.setDisplayName('Number of PV strings in series')
    series_modules.setDescription('Number of modules')
    args << series_modules

    pv_len = OpenStudio::Measure::OSArgument.makeDoubleArgument('pv_len', true)
    pv_len.setDisplayName('Length of PV array')
    pv_len.setDescription('In meters (m)')
    args << pv_len

    pv_wid = OpenStudio::Measure::OSArgument.makeDoubleArgument('pv_wid', true)
    pv_wid.setDisplayName('Width of PV array')
    pv_wid.setDescription('In meters (m)')
    args << pv_wid

    return args
  end

  # define what happens when the measure is run
  def run(workspace, runner, user_arguments)
    super(workspace, runner, user_arguments)

    # use the built-in error checking
    if !runner.validateUserArguments(arguments(workspace), user_arguments)
      return false
    end

    # assign the user inputs to variables
    batt_storage_capacity = runner.getStringArgumentValue('batt_storage_capacity', user_arguments)
    batt_discharge_power = runner.getStringArgumentValue('batt_discharge_power', user_arguments)
    batt_charge_power = runner.getStringArgumentValue('batt_charge_power', user_arguments)
    batt_initial_charge = runner.getStringArgumentValue('batt_initial_charge', user_arguments)

    pv_total_power = runner.getStringArgumentValue('pv_total_power', user_arguments)
    parallel_modules = runner.getStringArgumentValue('parallel_modules', user_arguments)
    series_modules = runner.getStringArgumentValue('series_modules', user_arguments)
    pv_len = runner.getStringArgumentValue('pv_len', user_arguments)
    pv_wid = runner.getStringArgumentValue('pv_wid', user_arguments)

    # check the user_name for reasonableness
    # if zone_name.empty?
    #   runner.registerError('Empty zone name was entered.')
    #   return false
    # end

    # get all thermal zones in the starting model
    # zones = workspace.getObjectsByType('Zone'.to_IddObjectType)

    # reporting initial condition of model
    # runner.registerInitialCondition("The building started with #{zones.size} zones.")

    # add a new surface for PV
    new_pv_surface_string = "
    Shading:Building,
      PV-surface,              !- Name
      180,                     !- Azimuth Angle {deg}
      20,                      !- Tilt Angle {deg}
      100,                      !- Starting X Coordinate {m}
      0,                       !- Starting Y Coordinate {m}
      0,                       !- Starting Z Coordinate {m}
      #{pv_len},                      !- Length {m}
      #{pv_wid};                       !- Height {m}
      "
    idfObject = OpenStudio::IdfObject.load(new_pv_surface_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_pv_surface = wsObject.get

    

    # add a new PV performance object. Assume square wafers with 90% packing density, 15% efficiency
    new_pv_performance_string = "
    PhotovoltaicPerformance:Simple,
      PV-performance,       !- Name
      0.90 ,                !- Fraction of Surface area that has active solar cells
      FIXED ,               !- Conversion efficiency input mode
      0.15 ,                !- Value for cell efficiency if fixed
      ;                     !- Name of Schedule that Defines Efficiency
      "
    idfObject = OpenStudio::IdfObject.load(new_pv_performance_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_pv_performance = wsObject.get

    # add a new PV generator object
    new_pv_generator_string = "
    Generator:Photovoltaic,
      PV-array,                                   !- Name
      PV-surface,                                 !- Surface Name
      PhotovoltaicPerformance:Simple,             !- Photovoltaic Performance Object Type
      PV-performance,                             !- Module Performance Name
      Decoupled,                                  !- Heat Transfer Integration Mode
      #{parallel_modules},                        !- Number of Series Strings in Parallel
      #{series_modules};                          !- Number of Modules in Series
      "
    idfObject = OpenStudio::IdfObject.load(new_pv_generator_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_pv_generator = wsObject.get

    # add a new generator list object
    new_generator_list_string = "
    ElectricLoadCenter:Generators,
      PV-gen-list,                                !- Name
      PV-array,                                   !- Generator 1 Name
      Generator:Photovoltaic,                     !- Generator 1 Object Type
      #{pv_total_power},                          !- Generator 1 Rated Electric Power Output
      ,                                           !- Generator 1 Availability Schedule Name
      ;                                           !- Generator 1 Rated Thermal to Electrical Power Ratio
      "
    idfObject = OpenStudio::IdfObject.load(new_generator_list_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_generator_list = wsObject.get

    # add a new inverter object
    new_inverter_string = "
    ElectricLoadCenter:Inverter:Simple,
      Simple Ideal Inverter,                  !- Name
      Always On,                              !- Availability Schedule Name
      ,                                       !- Zone Name
      0.0,                                    !- Radiative Fraction
      1.0;                                    !- Inverter Efficiency
      "
    idfObject = OpenStudio::IdfObject.load(new_inverter_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_inverter = wsObject.get

    # add a new battery object
    new_battery_string = "
    ElectricLoadCenter:Storage:Simple,
      Battery,                               !- Name
      ALWAYS_ON,                             !- Availability Schedule Name
      ,                                      !- Zone Name
      0.0,                                   !- Radiative Fraction for Zone Heat Gains
      0.7,                                   !- Nominal Energetic Efficiency for Charging
      0.7,                                   !- Nominal Discharging Energetic Efficiency
      #{batt_storage_capacity},              !- Maximum Storage Capacity {J}
      #{batt_discharge_power},               !- Maximum Power for Discharging {W}
      #{batt_charge_power},                  !- Maximum Power for Charging {W}
      #{batt_initial_charge};                                !- Initial State of Charge {J}
      "
    idfObject = OpenStudio::IdfObject.load(new_battery_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_battery = wsObject.get

    # add a new electric load center distributor
    # we need one distributor per generator if we mix AC and DC. Here, we can use a single distributor for DC generation from PV and storage into batteries.
    # Here, we set the operation scheme to try and meet all building loads using PV and batteries.
    new_electric_distributor_string = "
    ElectricLoadCenter:Distribution,
      On-site PV generation and storage,      !- Name
      PV-gen-list,                            !- Generator List Name
      TrackElectrical,                        !- Generator Operation Scheme Type
      0.0,                                    !- Demand Limit Scheme Purchased Electric Demand Limit {W}
      ,                                       !- Track Schedule Name Scheme Schedule Name
      ,                                       !- Track Meter Scheme Meter Name
      DirectCurrentWithInverterDCStorage,     !- Electrical Buss Type
      Simple Ideal Inverter,                  !- Inverter Object Name
      Battery;                                !- Electrical Storage Object Name
      "
    idfObject = OpenStudio::IdfObject.load(new_electric_distributor_string)
    object = idfObject.get
    wsObject = workspace.addObject(object)
    new_electric_distributor = wsObject.get

    # # echo the new zone's name back to the user, using the index based getString method
    # runner.registerInfo("A zone named '#{new_zone.getString(0)}' was added.")

    # # report final condition of model
    # finishing_zones = workspace.getObjectsByType('Zone'.to_IddObjectType)
    # runner.registerFinalCondition("The building finished with #{finishing_zones.size} zones.")

    return true
  end
end

# register the measure to be used by the application
AddBatteriesAndPV.new.registerWithApplication
