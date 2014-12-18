class Electricity

  setup: () ->
    divs = ['demand_chart', 'supply_chart', 'capacity_chart', 'emissions_chart']
    charts = d3.select("#results").selectAll(".chart")
      .data(divs)

    charts.enter()
      .append('div')
        .attr('id', Object)
        .attr('class', 'chart')

    @demand_chart = timeSeriesStackedAreaChart()
      .title("Electricity Demand")
      .unit('PJ/yr')
      .max_value(8000)

    @supply_chart = timeSeriesStackedAreaChart()
      .title("Electrity Supply")
      .unit('GW')
      .total_label('Total')
      .max_value(20000)

    @capacity_chart = timeSeriesStackedAreaChart()
      .title("Installed Capacity")
      .unit('GW')
      .total_label('Total')
      .max_value(500000)

    @emissions_chart = timeSeriesStackedAreaChart()
      .title("Emissions from Electricity")
      .unit('MtCO2e/yr')
      .total_label('Total')
      .min_value(-500)
      .max_value(1000)

    document.getElementById(d).style.width="22%" for d in divs

  teardown: () ->
    $('#results').empty()
    @demand_chart = null
    @supply_chart = null
    @capacity_chart = null
    @emissions_chart = null

  updateResults: (@pathway) ->
    @setup() unless @emissions_chart? && @demand_chart? && @supply_chart? && @capacity_chart?

    @demand_chart.context(@pathway.final_energy_demand.Total)

    # Create the basic charts of electricity
    d3.select('#demand_chart')
      .datum(d3.map(@pathway.electricity.demand))
      .call(@demand_chart)

    filtered = []
    for k,v of @pathway.electricity.supply
      if "CMJ "!=k.substring(0,4)
        filtered[k]=v
    @pathway.electricity.supply = filtered

    series = d3.map(@pathway.electricity.supply)
    # series.remove('Biomass/Coal power stations')
    series.remove('Non-thermal renewable generation')
    @supply_chart.context(@pathway.final_energy_demand.Total)

    d3.select('#supply_chart')
      .datum(series)
      .call(@supply_chart)

    series = d3.map(@pathway.electricity.capacity)
    d3.select('#capacity_chart')
      .datum(series)
      .call(@capacity_chart)

    @emissions_chart.context(@pathway.ghg.Total)

    d3.select('#emissions_chart')
      .datum(d3.map(@pathway.electricity.emissions))
      .call(@emissions_chart)

    # Now add shaded background of total energy demand to provide context
    #showContext( @pathway.final_energy_demand.Total, '#supply_chart', @supply_chart)
    #showContext( @pathway.ghg.Total, '#emissions_chart', @emissions_chart)

window.twentyfifty.views['electricity'] = new Electricity
