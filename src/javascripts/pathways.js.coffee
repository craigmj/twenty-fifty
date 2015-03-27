# This is the main controller of the view that the user sees.

# Each possible view the user sees (e.g., Electricity, Flows, Costs in Context) is
# defined in a separate javascript file in this folder. Each possible view then registers
# itself in this object, so by the time all the javascript is loaded it should have:
# views = {'electricity': new Electricity, 'sankey': new SankeyDisplay .... }
views = {}

# This keeps the settings for the current view
controller = null
choices = null
view = null
sector = null
comparator = '11111111111111111111111111111111111111111'

view_manager = null
old_choices = []

# This keeps a copy of previously requested pathways: so is a memory leak. 
cache = {}

# This timer is to debounce the resize
windowResizeDebounceTimer = null

# This is the first thing that is called when the page is loaded
documentReady = () ->
  checkSVGWorks()
  $('#cost_caveats').show() unless $.jStorage.get('CostCaveatShown') == true
  setUpControls()
  setVariablesFromURL()
  switchView(view)
  loadMainPathway()

$(document).ready(documentReady)

# This interface requires SVG to work. SVG is not supported in IE8 and earlier
# so we need to check for that and warn the user if it isn't going to work for
# them.
checkSVGWorks = () ->
  return true if !!document.createElementNS && !!document.createElementNS('http://www.w3.org/2000/svg', "svg").createSVGRect
  $("#svgWarn").show()

setUpControls = () ->
  # This ensures that any link with a 'title' attribute gets a tooltip
  $("a[title]").tooltip({delay: 0, position: 'top left', offset:[3,3],tip:'#tooltip'})
  
  # This allows the user to change a specific level
  $("a.choiceLink").click( (event) ->
    event.preventDefault()
    t = $(event.target)
    c = t.data().choicenumber
    l = t.data().choicelevel
    go(c, l)
  )

  # This allows the view to be changed
  $("a.view").click( (event) ->
    # Prevent the browser from trying to follow the link
    event.preventDefault()
    # Find the link that was clicked
    t = $(event.target)
    # Find the new view name from the link's data-view attribute
    v = t.data().view
    # Swithc the view
    switchView(v)
  )

  # This sets up the dropdown view and examples menus
  $(".newdropdown").click( (event) ->
    event.preventDefault()
    t = $(event.target)
    d = $(t.data().dropdown)
    if d.hasClass("showdropdown")
      d.removeClass("showdropdown")
    else
      d.addClass("showdropdown")
      o = t.offset()
      o.top = o.top + t.height()
      space = $(document).width() - o.left - d.width() # How much space between the right of the menu and the edge of the screen?
      o.left = o.left + space if space < 0 # Don't let the menu go off of the right of the screen
      d.offset(o)
  )

  $(window).resize( (event) ->
    clearTimeout(windowResizeDebounceTimer)
    windowResizeDebounceTimer = setTimeout( () ->
      view_manager.updateResults(cache[codeForChoices()])
    , 500)
  )

# This looks at the current URL which should be of the format
# /pathways/code or
# /pathways/code/view or
# /pathways/code/costs_compared_within_sector/sector_name or
# /pathways/code/view/comparator/comparator_code
# 
setVariablesFromURL = () ->
  url_elements = window.location.pathname.split( '/' )
  controller = url_elements[1] || "pathways"
  choices = choicesForCode(url_elements[2] || twentyfifty.default_pathway )
  view = url_elements[3] || "primary_energy_chart"
  if view == 'costs_compared_within_sector'
    sector = url_elements[4]
  if url_elements[4] == 'comparator'
    comparator = url_elements[5]

# When the user makes their choices, they are assembled into an array [1, 1.3, 2, 0, 1 ... ]
# This is turned into a URL 1d201 ... by turning non-integers into letters.
float_to_letter_map = { "":"0", 1.0:"1", 1.1:"b", 1.2:"c", 1.3:"d", 1.4:"e", 1.5:"f", 1.6:"g", 1.7:"h", 1.8:"i", 1.9:"j", 2.0:"2", 2.1:"l", 2.2:"m", 2.3:"n", 2.4:"o", 2.5:"p", 2.6:"q", 2.7:"r", 2.8:"s", 2.9:"t", 3.0:"3", 3.1:"v", 3.2:"w", 3.3:"x", 3.4:"y", 3.5:"z", 3.6:"A", 3.7:"B", 3.8:"C", 3.9:"D", 0.0:"0", 4.0:"4"}

codeForChoices = (c = choices) ->
  cd = for choice in c
    float_to_letter_map[choice]
  cd.join('')

# This carries out the inverse of codeForChoices. It turns 1d201 into [1, 1.3, 2, 0, 1 ...]
letter_to_float_map = {"1":1.0, "b":1.1, "c":1.2, "d":1.3, "e":1.4, "f":1.5, "g":1.6, "h":1.7, "i":1.8, "j":1.9, "2":2.0, "l":2.1, "m":2.2, "n":2.3, "o":2.4, "p":2.5, "q":2.6, "r":2.7, "s":2.8, "t":2.9, "3":3.0, "v":3.1, "w":3.2, "x":3.3, "y":3.4, "z":3.5, "A":3.6, "B":3.7, "C":3.8, "D":3.9, "0":0.0, "4":4.0}

choicesForCode = (newCode) ->
  for choice in newCode.split('')
    letter_to_float_map[choice]



url = (options = {}) ->
  s = jQuery.extend({controller:controller, code: codeForChoices(), view:view, sector:sector, comparator: getComparator()},options)
  if s.view == 'costs_compared_within_sector' && s.sector?
    "/#{s.controller}/#{s.code}/#{s.view}/#{s.sector}"
  else if s.comparator?
    "/#{s.controller}/#{s.code}/#{s.view}/comparator/#{s.comparator}"
  else
    "/#{s.controller}/#{s.code}/#{s.view}"

go = (index,level) ->
  old_choices = choices.slice(0)
  # In the South Africa model, we don't permit partial values for pathways
  if false && index <= 15 && index !=3 && level > 1 && Math.ceil(choices[index]) == level
    choices[index] = Math.round((choices[index] - 0.1)*10)/10
  else
    choices[index] = level
  loadMainPathway()

demoTimer = null
demoOriginalLevel = null

startDemo = (choice) ->
  demoLevel = 1
  demoOriginalLevel = choices[choice]
  demoMaximum = window.twentyfifty.choice_sizes[choice]
  demoTimer = setInterval( (() ->
    go(choice,demoLevel)
    demoLevel = demoLevel + 1
    demoLevel = 1 if demoLevel > demoMaximum
    false
  ),1000)

stopDemo = (choice) ->
  clearInterval(demoTimer) if demoTimer?
  go(choice,demoOriginalLevel) if demoOriginalLevel? && demoOriginalLevel != choices[choice]

# If you want to programatically change the view, use this method
#   new_view: the name of the new view. Choices include 'electricity' and 'primary_energy'
switchView = (new_view) ->
  # Close the menu
  $('.showdropdown').removeClass("showdropdown")

  # Don't switch if we are already on that view
  return false if view == new_view and view_manager?
  
  # This removes the old information from the screen
  view_manager.teardown() if view_manager?

  # Load the new view manager
  view = new_view
  view_manager = views[view]

  # Remove the 'selectedView' class from old links and add to new
  $("a.selectedView").removeClass("selectedView")
  $("a.view[data-view='#{view}']").addClass("selectedView")

  # Special case for cost views from dropdown method
  if view == "costs_in_context"
    $("#cost_choice").addClass("selectedView").text("Costs: context")
  else if view == "costs_compared_overview"
    $("#cost_choice").addClass("selectedView").text("Costs: compared")
  else if view == "costs_sensitivity"
    $("#cost_choice").addClass("selectedView").text("Costs: sensitivity")
  else
    $("#cost_choice").text("Costs")

  # Get the id for this pathway
  c = codeForChoices()
  # Check if the data is loaded
  data = cache[c]
  
  # If the data is loaded, get the view_manager to draw the view
  view_manager.updateResults(data) if data?
  
  # This updates the url, on browsers that support this (i.e., not IE <9)
  history.pushState(choices, c, url()) if history['pushState']?

switchPathway = (new_code) ->
  setChoices choicesForCode(new_code)

setChoices = (new_choices) ->
  $('.showdropdown').removeClass("showdropdown")
  old_choices = choices.slice(0)
  choices = new_choices
  loadMainPathway()

loadMainPathway = (pushState = true) ->
  # Check if we haven't really moved
  return false if choices.join('') == old_choices.join('')

  # Update the controls, if neccesarry
  updateControls(old_choices,choices)
  
  # Change the url if we can
  main_code = codeForChoices()
  history.pushState(choices,main_code,url()) if history['pushState']?
  
  # Check the cache
  if cache[main_code]?
    view_manager.updateResults(cache[main_code])
    $('#calculating').hide()
  else
    $('#calculating').show()
    fix_data_cost_components = (cc)->
      fix_low_high = (low,pt,high)->
        if 0==low
          low = pt
        if 0==high
          high = pt
        return [low,pt,high]
      for k,v of cc
        for prefix in ['', 'finance_']
          [v[prefix + "low"], v[prefix+"point"], v[prefix+"high"]] = 
            fix_low_high(v[prefix + "low"], v[prefix+"point"], v[prefix+"high"])
        cc[k] = v
        return
      cc

    fetch = () ->
      $.getJSON(url({code:main_code, view:'data', sector: null, comparator: null}), (data) ->
        if data?
          cache[data._id] = data
          # CMJ150107 - CostComponents fixes for low and point
          # data["cost_components"] = fix_data_cost_components(data["cost_components"])
          # CMJ150107 - Making these fixes in model_result.rb now
          if data._id == codeForChoices()
            view_manager.updateResults(data)
            $('#calculating').hide()
      )
    
    fetch()

loadSecondaryPathway = (secondary_code,callback) ->
  if cache[secondary_code]?
    callback(cache[secondary_code])
  else
    fetch = () =>
      $.getJSON(url({code:secondary_code, view:'data', sector: null, comparator: null}), (data) =>
        if data?
          cache[data._id] = data
          callback(data)
      )
    fetch()
  
window.onpopstate = (event) ->
  return false unless event.state
  url_elements = window.location.pathname.split( '/' )
  setChoices(choicesForCode(url_elements[2]))
  switchView(url_elements[3])
  if view == 'costs_compared_within_sector'
    switchSector(url_elements[4])
  if url_elements[4] == 'comparator'
    switchComparator(url_elements[5])

updateControls = (old_choices,@choices) ->
  controls = $('#classic_controls')
  for choice, i in @choices
    old_choice = old_choices[i]
    unless choice == old_choices[i]

      old_choice_whole = Math.ceil(old_choice)
      old_choice_frview = parseInt((old_choice % 1)*10)
      
      choice_whole = Math.ceil(choice)
      choice_frview = parseInt((choice % 1)*10)
            
      row = controls.find("tr#r#{i}")
      
      # Revert the old
      row.find(".selected, .level#{old_choice_whole}, .level#{old_choice_whole}_#{old_choice_frview}").removeClass("selected level#{old_choice_whole} level#{old_choice_whole}_#{old_choice_frview}")
      unless old_choice_frview == 0
        controls.find("#c#{i}l#{old_choice_whole}").text(old_choice_whole)
      
      # Setup the new
      row.find("#c#{i}l#{choice_whole}").addClass('selected')
      
      for c in [1..(choice_whole-1)]
        controls.find("#c#{i}l#{c}").addClass("level#{choice_whole}")
      unless choice_frview == 0
        controls.find("#c#{i}l#{choice_whole}").text(choice)
        controls.find("#c#{i}l#{choice_whole}").addClass("level#{choice_whole}_#{choice_frview}")
      else
        controls.find("#c#{i}l#{choice_whole}").addClass("level#{choice_whole}")


# This is only relevant for the costs by sector view
getSector = () -> parseInt(sector)
    
# This is only relevant for the costs by sector view
switchSector = (new_sector) ->
  sector = new_sector
  history.pushState(choices, codeForChoices(), url()) if history['pushState']?
  switchView('costs_compared_within_sector')
  view_manager.teardown()
  view_manager.updateResults(cache[codeForChoices()])

# This is only relevant for the costs sensitivity view
getComparator = () ->
  comparator

# This is only relevant for the costs sensitivity view
switchComparator = (new_comparator) ->
  comparator = new_comparator
  history.pushState(choices, codeForChoices(), url()) if history['pushState']?
  view_manager.switchComparator(comparator) if view_manager.switchComparator?

# Given a pathway id (e..g, 103a2...) sees if we have an example pathway that matches
# and, if so, returns the name of that example pathway
pathwayName = (pathway_code,default_name = null) ->
  window.twentyfifty.pathway_names_hash[pathway_code] || default_name

# Given a pathway id (e..g, 103a2...) sees if we have an example pathway that matches
# and, if so, returns the description of that example pathway
pathwayDescriptions = (pathway_code,default_description = null) ->
  window.twentyfifty.pathway_descriptions_hash[pathway_code] || default_description

# Given a pathway id (e..g, 103a2...) sees if we have an example pathway that matches
# and, if so, returns the id of the page on the wiki that describes it
pathwayWikiPages = (pathway_code,default_page = null) ->
  "http://2050-calculator-tool-wiki.decc.gov.uk/pages/#{window.twentyfifty.pathway_wiki_pages_hash[pathway_code] || default_page}"

getChoices = () -> choices

window.twentyfifty.code = codeForChoices
window.twentyfifty.getChoices = getChoices
window.twentyfifty.setChoices = setChoices
window.twentyfifty.getSector = getSector
window.twentyfifty.switchSector = switchSector
window.twentyfifty.getComparator = getComparator
window.twentyfifty.switchComparator = switchComparator
window.twentyfifty.url = url
window.twentyfifty.go = go
window.twentyfifty.loadMainPathway = loadMainPathway
window.twentyfifty.loadSecondaryPathway = loadSecondaryPathway
window.twentyfifty.switchView = switchView
window.twentyfifty.switchPathway = switchPathway
window.twentyfifty.pathwayName = pathwayName
window.twentyfifty.pathwayDescriptions = pathwayDescriptions
window.twentyfifty.pathwayWikiPages = pathwayWikiPages
window.twentyfifty.startDemo = startDemo
window.twentyfifty.stopDemo = stopDemo

window.twentyfifty.views = views

