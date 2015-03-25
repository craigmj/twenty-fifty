class SankeyDisplay
  
  name_conversions =
    "H2":"Hydrogen"
    # "UK land based bioenergy":"Forests & biocrops"
    # "Bio-conversion":"Biomass processing"
    # "H2 conversion":"Hydrogen production"
    # "H2":"Hydrogen"
    # "Useful district heat":"Delivered heat"
    # "Heating and cooling - homes":"Home heating & cooling"
    # "Heating and cooling - commercial":"Office heating & cooling"
    # "Lighting & appliances - homes":"Home lighting & appliances"
    # "Lighting & appliances - commercial":"Office lighting & appliances"

  convert_name = (name) ->
    name_conversions[name] || name
  
  constructor: () ->
    @lowercase=true
  
  trimSankeyLabels: (data)->
    if @lowercase
      ([d[0].trim().toLowerCase(), d[1], d[2].trim().toLowerCase()] for d in data)
    else
      ([d[0].trim(), d[1], d[2].trim()] for d in data)

  removeLiquidLoop: (data)->
      data
      # res = []
      # for d in data
      #     do (d)->
      #         if d[0]!="Electricity grid" || (d[2]!="Gas to Liquid" && d[2]!="Coal to Liquid")
      #             res.push(d)
      # res

  updateResults: (pathway) ->
    @setup() unless @s?
    data = @trimSankeyLabels(pathway.sankey)
    # data = pathway.sankey
    if @drawn == true
      @s.updateData(data)
      @s.redraw()
    else
      @s.setData(data)
      @s.draw()
      @drawn = true
    # max_y = @s.boxes['Losses'].b()
    # console.log max_y
    max_y = 400
    # console.log("max_y=", max_y, " and sankey.height()=", $('#sankey').height())
    if $('#sankey').height() < max_y
      $('#sankey').height(max_y)
      @s.r.setSize($('#sankey').width(),max_y)
      #@s.redraw()

  teardown: () ->
    $('#results').empty()
    @s = null

  setup: () ->
    return false if @s?
    $('#results').append("<div id='sankey'></div>")

    @s = new Sankey()

    s0 = ["crude oil","coal","natural gas","biomass","nuclear fuel","solar","wind","hydro","electricity exports","electricity imports"]
    s1= ["crude refineries","coal direct", "synthetic fuels", 
    "biofuels refining","natural gas direct","biomass direct","electricity generation",
      "electricity exports 2"
    ]
    s2 = ["coal final","liquid fuels","natural gas final","biomass final","electricity"]
    s3 = ["households","transport","agriculture","commercial","industry",
    "coal exports","losses"]
    
    @s.stack(0, s0)
    @s.stack(1, s1)
    @s.stack(2, s2)
    @s.stack(3, s3)


    
    maxTWh = 35000
    pixels_per_TWh = $('#sankey').height() / maxTWh

    @s.y_space = Math.round(600 * pixels_per_TWh)
    @s.right_margin = 250
    @s.left_margin = 150

    # # Nudge
    @s.nudge_boxes_callback = () =>
      spread = (boxset)=>
        total = 0
        for b in boxset 
          do (b)->
            if b?
              total += b.size()
        # console.log?("Total boxset size for ", boxset, " = ", total)
        space = ($('#sankey').height()/3 - @s.y_space) / (boxset.length-1)
        # space  = 100
        console.log?("space = #{space}")
        y = 0
        for b in boxset 
          do (b)=>
            # console.log?("b=", b, ", y=#{y}")
            if b?
              if 0==y
                y = @s.y_space
              else
                y += space
              b.y = y
              y += b.size()
            return


    #   this.boxes["Losses"].y =  this.boxes["Marine algae"].b() - this.boxes["Losses"].size()
    #   # @s.boxes["Exports"].y =  @s.boxes["Losses"].y - @s.boxes["Exports"].size() - y_space)
    #   # @s.boxes["Over generation / exports"].y =  @s.boxes["Exports"].y - @s.boxes["Over generation / exports"].size() - y_space)
      spreadBoxes = (set)=>
        console.log("set=", set)
        spread(@s.boxes[i] for i in set)
      spreadBoxes(s) for s in [s0, s1, s2, s3]
    
    # # Colours
    @s.setColors({
    #   "H2 conversion":"#FF6FCF", 
    #   "Final electricity":"#0000FF", 
    #   "Over generation / exports":"#0000FF", 
    #   "H2":"#FF6FCF"
    })
    
    # Add the emissions
    # @s.boxes["Thermal generation"].ghg = 100
    # @s.boxes["CHP"].ghg = 10
    # @s.boxes["UK land based bioenergy"].ghg = -100
    # @s.boxes["Heating and cooling - homes"].ghg = 20
    
    # Fix some of the colours
    @s.nudge_colours_callback = () ->
      # console.log @boxes["Electricity grid"].left_lines
      # @recolour(@boxes["Losses"].left_lines,"#ddd")
      # @recolour(@boxes["District heating"].left_lines,"#FF0000")
      # @recolour(@boxes["Electricity grid"].left_lines,"#0000FF")

    
    @s.convert_flow_values_callback = (flow) ->
      return flow * pixels_per_TWh # Pixels per TWh
    
    @s.convert_flow_labels_callback = (flow) ->
      return Math.round(flow)
    
    @s.convert_box_value_labels_callback = (flow) ->
      return (""+Math.round(flow)+" TWh/y")

window.twentyfifty.views['sankey'] = new SankeyDisplay
