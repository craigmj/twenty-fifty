class Story

  constructor: () ->
    @ready = false
  
  setup: () ->
    # $("#results").append("<div id='stories'></div>")
    @ready = true
  
  teardown: () ->
    $("#results").empty()
    @ready = false

  updateResults: (@pathway) ->
    @setup() unless @ready
    d = document.createElement('div')
    d.setAttribute('id','thestory')
    for r in @pathway.story
      do (r)->
        d.appendChild(h = document.createElement('span'))
        h.className = "story_#{r[0]}"
        h.appendChild(document.createTextNode(r[1]))
        if 0!=r[2]
          d.appendChild(c = document.createElement('div'))
          c.className = 'info'
          c.appendChild(document.createTextNode(r[2]))
        return
    $('#results').empty()
    document.getElementById('results').appendChild(d)
    return

  stories_for_choices: (element,title,rows...) ->
    element.append("<h4>#{title}</h4>") if title?
    text = []
    for row in rows
      choice = choices[row] - 1
      if choice % 1 == 0.0
        text.push(window.twentyfifty.longDescriptions[row][choice])
      else
        text.push("Between #{window.twentyfifty.longDescriptions[row][Math.floor(choice)]} and #{window.twentyfifty.longDescriptions[row][Math.ceil(choice)]}")
      
    element.append("<p>#{text.join(". ")}.</p>")
  
  heating_choice_table: (element,heat) ->
    html = []
    html.push "<table class='heating_choice'>"
    html.push "<tr><th>Type of heater</th><th class='target'>2050 proportion of heating</th></tr>"
    values = []
    for own name, value of heat
      values.push({name:name,value:value})
    values.sort((a,b) -> a.value - b.value)
    for value in values
      if value.value > 0.01
        html.push "<tr><td>#{value.name}</td><td class='target'>#{Math.round(value.value*100)}%</td></tr>"
    html.push "</table>"    
    element.append(html.join(''))
    
  electricity_generation_capacity_table: (element) ->
    html = []
    html.push "<table class='heating_choice'>"
    html.push "<tr><th>GW Capacity</th><th class='target'>2010</th><th class='target'>2050</th></tr>"
    values = []
    for own name, data of @pathway.electricity.capacity
      values.push({name:name,d2010:data[0],d2050:data[8]})
    values.sort((a,b) -> a.d2050 - b.d2050)
    for value in values
      unless (value.d2010+value.d2050) == 0.0
        html.push "<tr><td>#{value.name}</td><td class='target'>#{Math.round(value.d2010)}</td><td class='target'>#{Math.round(value.d2050)}</td></tr>"
    html.push "</table>"
    element.append(html.join(''))
      

window.twentyfifty.views['story'] = new Story
