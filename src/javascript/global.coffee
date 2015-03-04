d3 = require 'd3'
$ = require 'jQuery'

window.BarChart =
  barHeight: 34
  width: 420
  init: ->
    @width = $('.chart').width()
    $('.chart').height(DATA.length * (@barHeight))

  clean_num: (num) ->
    parseFloat num.replace(",", "") if typeof num is "string"
  getXData: (key) ->
    DATA.map (data) =>
      @clean_num data[key]

  renderGraph: (key) ->
    $('h2.operation').text(key)
    @init()
    X_DATA = @getXData(key)
    x = d3.scale.linear()
          .domain([0, d3.max(X_DATA)])
          .range([0, @width])

    @chart = d3.select(".chart")
      .attr("width", @width)
      .attr("height", @barHeight * X_DATA.length)

    @bar = @chart.selectAll('g')
        .data(DATA)
      .enter().append("g")
        .attr("transform", (d, i) => "translate(0, #{i * @barHeight})")

    @bar.append('rect')
        # .attr('width', x)
        .attr('width', (d) => x(@clean_num d[key]))
        .attr('height', @barHeight - 3)

    @bar.append("text")
        .attr("x", (d) =>
          Math.max(
            x(@clean_num d[key]) - 3,
            40
          ) or 40
        )
        .attr("y", @barHeight - 10)
        .attr("dy", ".35em")
        .text (d) -> d[key]

    @bar.append("text")
        .attr('class', 'name')
        .attr("x", 3)
        .attr("y", 10)
        .attr("dy", ".35em")
        .text (d) -> d["Type of Train"]

  updateGraph: (key) ->
    $('h2.operation').text(key.replace(/with /i, 'w/'))
    X_DATA = @getXData(key)
    x = d3.scale.linear()
          .domain([0, d3.max(X_DATA)])
          .range([0, @width])

    @chart.attr("height", @barHeight * X_DATA.length)
    @bar.data(DATA)
      .transition()
      .select('rect')
        .attr('width', (d) =>
          x(@clean_num d[key]) or 0
        )

    @bar.transition()
      .select("text")
        .attr("x", (d) =>
          Math.max(
            x(@clean_num d[key]) - 3,
            40
          ) or 40
        )
        .attr("dy", ".35em")
        .text (d) ->
          d[key]

  showOperations: ->
    _ = require 'underscore'
    operations = _.keys(DATA[0])
    operations.shift()

    i = 0
    for operation in operations
      display_operation = operation
                    .toLowerCase()
                    # .replace("inpatient", "(in)")
                    # .replace("outpatient", "(out)")
                    # .replace("with ", "w/")
      i++
      $('.operations').append """
        <div class="operation" data-op="#{operation}">
         #{display_operation}
        </div>
      """
      $('.operations').append "<br>" if i is 2

    $('div.operation').first().addClass('selected')

    $('div.operation').on 'click', (e) =>
      $el = $(e.target)
      @updateGraph $el.data('op')

      $('.selected').removeClass('selected')
      $el.addClass('selected')



BarChart.showOperations()
BarChart.renderGraph("Number Of Trains")
