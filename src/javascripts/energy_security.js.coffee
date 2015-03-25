class EnergySecurity

  constructor: () ->
    @long_descriptions = twentyfifty.longDescriptions

  setup: () ->
    @ready = true
    $('#results').append("<div id='energysecurity'><div id='balancing' class='column'></div><div id='imports' class='column'></div><div id='diversity' class='column'></div><div class='clear'></div></div>")

  teardown: () ->
    @ready = false
    $('#results').empty()

  updateResults: (@pathway) ->
    @setup() unless @ready
    @updateBalancingSection()
    @updateImportsSection()
    @updatedDiversitySection()
  
  updateBalancingSection: () ->
    element = $('#balancing')
    element.empty()
    # Removed per Katye telcon 2015-03-03
    #element.append("<h2>Balancing electricity supply and demand</h2>")
    #if @pathway.electricity.automatically_built > 0
    #  element.append("<p>#{Math.round(@pathway.electricity.automatically_built)} GW of conventional gas electricity generation plant has been assumed to have been built by 2050, to cover the gap between average electricity demand and the amount of low carbon generation selected in this pathway.</p>")
    #element.append("<p>This tool does not model the hourly, daily or even seasonal operation of the electricity grid. It presents annual averages. Therefore it does not correctly represent the peaks and troughs of electricity demand.<p>")
    #element.append("<p>To go some way to addressing this flaw, the tool applies a simulated stress test to your pathway of five cold, almost windless, days.")
    #element.append("In this case, the stress test implies that #{Math.round(@pathway.electricity.peaking)} GW of additional peaking plant may be required for supply to meet demand over that period.</p>")

  updateImportsSection: () ->
    element = $('#imports')
    element.empty()
    element.append("<h2>Dependence on imported energy</h2>")
    element.append("<p>The calculator assumes that any available biomass is preferred over fossil fuels and that domestically produced fuels are preferred over imports. It assumes that fossil fuels are imported to cover any shortfall.</p>")
    element.append("<table class='imports'>")
    element.append("<tr><th class='description'></th><th colspan='2' class='year'>2006</th><th></th><th colspan='2' class='year'>2050</th></tr>")
    element.append("<tr><th class='description'>Imports</th><th class='value'>PJ/yr</th><th class='value'>%</th><th></th><th class='value'>PJ/yr</th><th class='value'>%</th></tr>")
    for own name, values of @pathway.imports
      element.append("<tr><td class='description'>#{name}</td><td class='value'>#{values['2007'].quantity}</td><td class='value'>#{values['2007'].proportion}</td><td>&nbsp;</td><td class='value'>#{values['2050'].quantity}</td><td class='value'>#{values['2050'].proportion}</td></tr>")
    element.append("</table>")

  updatedDiversitySection: () ->
    element = $('#diversity')
    element.empty()
    element.append("<h2>Diversity of energy sources</h2>")
    element.append("<p>There may be a benefit from maintaining a diversity of energy sources:</p>")
    element.append("<table class='imports'>")
    element.append("<tr><th class='description'>Proportion of energy supply</th><th class='value'>2006</th><th></th><th class='value'>2050</th></tr>")
    for own name, values of @pathway.diversity
      unless values['2007'] == "0%" && values['2050'] == "0%"
        element.append("<tr><td class='description'>#{name}</td><td class='value'>#{values['2007']}</td><td>&nbsp;</td><td class='value'>#{values['2050']}</td></tr>")
    element.append("</table>")


    # totals = @pathway.primary_energy_supply['Total Primary Supply']
    # sw = [0,0,0,0,0,0,0,0,0]
    # for own form, values of @pathway.primary_energy_supply
    #   unless form == "Total Primary Supply"
    #     for value, i in values
    #       unless value == 0
    #         share = value / totals[i]
    #         natural_log_share = Math.log(share)
    #         # console.log share, natural_log_share
    #         sw[i] += (share * -natural_log_share)
    # element.append("<p>TBD - Shannon-Wiener measure</p>")
    # element.append("<p>TBD - Higher is better, numbers below buggy?</p>")    
    # element.append("<table>")
    # element.append("<tr><th class='description'>Year</th><th class='value'>SW</th></tr>")
    # for value, i in sw
    #   element.append("<tr><td class='description'>#{i}</td><td class='value'>#{value}</td></tr>")
    # element.append("</table>")

window.twentyfifty.views['energy_security'] = new EnergySecurity


