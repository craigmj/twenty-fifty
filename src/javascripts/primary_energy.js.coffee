class PrimaryEnergy

  setup: () ->
    charts = d3.select("#results").selectAll(".chart")
      .data(['demand_chart', 'supply_chart', 'emissions_chart'])

    charts.enter()
      .append('div')
        .attr('id', Object)
        .attr('class', 'chart')

    @final_energy_chart = timeSeriesStackedAreaChart()
      .title("Final Energy Demand")
      .unit('PJ/yr')
      .total_label('Total')
      .max_value(18000)

    @primary_energy_chart = timeSeriesStackedAreaChart()
      .title("Primary Energy Supply")
      .unit('PJ/yr')
      .total_label('Total used in ZA')
      .max_value(18000)

    @emissions_chart = timeSeriesStackedAreaChart()
      .title("Greenhouse Gas Emissions")
      .unit('MtCO2e/yr')
      .total_label('Total')
      .min_value(-500)
      .max_value(2000)

  teardown: () ->
    $('#results').empty()
    @final_energy_chart = null
    @primary_energy_chart = null
    @emissions_chart = null

  fixGraphData: (map)->
    out = {}
    for k,v of map
      if not ("0"==k)
        out[k] = v
    out

  updateResults: (@pathway) ->
    @setup() unless @emissions_chart? && @final_energy_chart? && @primary_energy_chart?

    @pathway.primary_energy_supply = @fixGraphData(@pathway.primary_energy_supply)
    @pathway.final_energy_demand = @fixGraphData(@pathway.final_energy_demand)

    d3.select('#demand_chart')
      .datum(d3.map(@pathway.final_energy_demand))
      .call(@final_energy_chart)

    @pathway.primary_energy_supply = @fixGraphData(@pathway.primary_energy_supply)

    d3.select('#supply_chart')
      .datum(d3.map(@pathway.primary_energy_supply))
      .call(@primary_energy_chart)

    series = d3.map(@pathway.ghg)
    series.remove("percent_reduction_from_1990")
    percent = @pathway.ghg.percent_reduction_from_1990

    d3.select('#emissions_chart')
      .datum(series)
      .call(@emissions_chart)

    t = d3.select('#emissions_chart g.drawing')
          .selectAll('text.target')
            .data([percent])

    t.enter()
      .append('text')
        .attr('class','target')

    t.attr('transform', 'translate('+@emissions_chart.x_center()+',-18)')

    t.transition()
      .tween('text', (d) ->
        current = parseInt(@textContent) || +d
        i = d3.interpolateRound(current, +d)
        # (t) ->
        #   @textContent = "#{i(t)}% reduction 1990-2050"
      )

    txt = document.getElementById('emissions_chart_ppd')
    if null==txt
      txt = $('<div id="emissions_chart_ppd" style="margin-left: 2em;">' +
          '<table><tbody><tr><td>' +
            '<div style="display:inline-block; background-color:#75bf75; width:2em; ' +
            'height:2em; position:relative; top:0.7em; margin-right: 1em;"></div>' +
          '</td><td>' +
          'The National GHG Emissions Trajectory Range: Peak, Plateau and Decline (PPD)' +
          '</td></tr></tbody></table>' +
          '</div>')
      $('#emissions_chart').append(txt)

  zoom: () ->
    d3.select("#demand_chart")
      .attr("style", "width: 60%")

    @updateResults(@pathway)

  unzoom: () ->
    d3.select("#demand_chart")
      .attr("style", null)

    @updateResults(@pathway)


window.twentyfifty.views['primary_energy_chart'] = new PrimaryEnergy
