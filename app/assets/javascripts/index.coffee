$ ->
    ws = new WebSocket $("body").data("ws-url")
    ws.onmessage = (event) ->
        message = JSON.parse event.data
        switch message.type
            when "stockhistory"
                populateStockHistory(message)
                $(".removesymbolform").click (event) ->
                    event.preventDefault()
                    # send the message to watch the stock
                    ws.send(JSON.stringify({action: "remove", symbol: event.target.id}))
            when "stockupdate"
                updateStockChart(message)
            when "stockremove"
                removeStockChart(message)
            else
                console.log(message)

    $("#addsymbolform").submit (event) ->
        event.preventDefault()
        # send the message to watch the stock
        ws.send(JSON.stringify({action: "add", symbol: $("#addsymboltext").val()}))
        # reset the form
        $("#addsymboltext").val("")

getPricesFromArray = (data) ->
  (v[1] for v in data)

getChartArray = (data) ->
  ([i, v] for v, i in data)

getChartOptions = (data) ->
  series:
    shadowSize: 0
  yaxis:
    min: getAxisMin(data)
    max: getAxisMax(data)
  xaxis:
    show: false

getAxisMin = (data) ->
  Math.min.apply(Math, data) * 0.9

getAxisMax = (data) ->
  Math.max.apply(Math, data) * 1.1

populateStockHistory = (message) ->
  console.log(message)
  chart = $("<div>").addClass("chart").prop("id", message.symbol)
  chartHolder = $("<div>").addClass("chart-holder").append(chart)
  price = $("<h2>").addClass("price").prop("id", "price-"+message.symbol).text("$"+message.history[0])
  chartHolder.append(price)
  removeBtn = $("<button>").addClass("btn").addClass("removesymbolform").prop("id", message.symbol).text("Remove Stock")
  chartHolder.append(removeBtn)
  detailsHolder = $("<div>").addClass("details-holder")
  flipper = $("<div>").addClass("flipper").append(chartHolder).append(detailsHolder).attr("data-content", message.symbol)
  flipContainer = $("<div>").addClass("flip-container").prop("id", "flipper-"+message.symbol).append(flipper)
  $("#stocks").prepend(flipContainer)
  plot = chart.plot([getChartArray(message.history)], getChartOptions(message.history)).data("plot")

updateStockChart = (message) ->
  if ($("#" + message.symbol).size() > 0)
    console.log($("#price-"+message.symbol))
    $("#price-"+message.symbol).text(message.price)
    plot = $("#" + message.symbol).data("plot")
    data = getPricesFromArray(plot.getData()[0].data)
    data.shift()
    data.push(message.price)
    plot.setData([getChartArray(data)])
    # update the yaxes if either the min or max is now out of the acceptable range
    yaxes = plot.getOptions().yaxes[0]
    if ((getAxisMin(data) < yaxes.min) || (getAxisMax(data) > yaxes.max))
      # reseting yaxes
      yaxes.min = getAxisMin(data)
      yaxes.max = getAxisMax(data)
      plot.setupGrid()
    # redraw the chart
    plot.draw()

removeStockChart = (message) ->
    console.log(message)
    # find element with id == symbol and class == flipper-container
    # remove this element from the dom
    id = "#flipper-" + message.symbol
    console.log(id)
    $(id).remove()

# handleFlip = (container) ->
#   if (container.hasClass("flipped"))
#     container.removeClass("flipped")
#     container.find(".details-holder").empty()
#   else
#     container.addClass("flipped")
#     # fetch stock details and tweet
#     $.ajax
#       url: "/sentiment/" + container.children(".flipper").attr("data-content")
#       dataType: "json"
#       context: container
#       success: (data) ->
#         detailsHolder = $(this).find(".details-holder")
#         detailsHolder.empty()
#         switch data.label
#           when "pos"
#             detailsHolder.append($("<h4>").text("The tweets say BUY!"))
#             detailsHolder.append($("<img>").attr("src", "/assets/images/buy.png"))
#           when "neg"
#             detailsHolder.append($("<h4>").text("The tweets say SELL!"))
#             detailsHolder.append($("<img>").attr("src", "/assets/images/sell.png"))
#           else
#             detailsHolder.append($("<h4>").text("The tweets say HOLD!"))
#             detailsHolder.append($("<img>").attr("src", "/assets/images/hold.png"))
#       error: (jqXHR, textStatus, error) ->
#         detailsHolder = $(this).find(".details-holder")
#         detailsHolder.empty()
#         detailsHolder.append($("<h2>").text("Error: " + JSON.parse(jqXHR.responseText).error))
#     # display loading info
#     detailsHolder = container.find(".details-holder")
#     detailsHolder.append($("<h4>").text("Determing whether you should buy or sell based on the sentiment of recent tweets..."))
#     detailsHolder.append($("<div>").addClass("progress progress-striped active").append($("<div>").addClass("bar").css("width", "100%")))
