ttm = thinkthroughmath
class_mixer = ttm.class_mixer
expression_to_string = ttm.lib.math.ExpressionToString
historic_value = ttm.lib.historic_value

ui_elements = ttm.widgets.UIElements.build()
math_buttons_lib = ttm.widgets.ButtonBuilder
components = ttm.lib.math.ExpressionComponentSource.build()


calculator_wrapper_class = 'javascript-calculator'


open_widget_dialog = (element)->
  if element.empty()
    Calculator.build_widget(element)
  element.dialog(dialogClass: "calculator-dialog", title: "Calculator")
  element.dialog("open")
  element.dialog({ position: { my: 'right center', at: 'right center', of: window}})

class Calculator
  @build_widget: (element, buttonsToRender=null)->
    math = ttm.lib.math.math_lib.build()
    Calculator.build(element, math, ttm.logger, buttonsToRender)

  initialize: (@element, @math, @logger, @buttonsToRender)->
    @view = CalculatorView.build(@, @element, @math, @buttonsToRender)
    @expression_position = historic_value.build()
    @updateCurrentExpressionWithCommand @math.commands.build_reset()

  displayValue: ->
    exp_pos = @expression_position.current()
    exp = exp_pos.expression()
    exp_contains_cursor = @math.traversal.build(exp_pos).buildExpressionComponentContainsCursor()
    if !exp.isError()
      val = expression_to_string.toHTMLString(exp_pos, exp_contains_cursor)
      if val.length == 0
        '0'
      else
        val
    else
      # @logger.warn("display value is error")
      @errorMsg()

  display: ->
    to_disp = @displayValue()
    # @logger.info("calculator display #{to_disp}")
    @view.display(to_disp)

  errorMsg: -> "Error"

  updateCurrentExpressionWithCommand: (command)->
    new_exp = command.perform(@expression_position.current())
    @reset_on_next_number = false
    @expression_position.update(new_exp)
    @display()
    @expression_position.current()

  # specification actions
  numberClick: (button_options)->
    if @reset_on_next_number
      @reset_on_next_number = false
      @updateCurrentExpressionWithCommand @math.commands.build_reset()

    cmd = @math.commands.build_append_number(value: button_options.value)
    @updateCurrentExpressionWithCommand cmd

  exponentClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_exponentiate_last()

  negativeClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_negate_last()

  additionClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_addition()

  multiplicationClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_multiplication()

  divisionClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_division()

  subtractionClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_subtraction()

  decimalClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_decimal()

  # command actions
  clearClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_reset()

  equalsClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_calculate()
    @reset_on_next_number = true

  squareClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_square()
    @reset_on_next_number = true

  squareRootClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_square_root()
    @reset_on_next_number = true

  lparenClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_sub_expression()

  rparenClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_exit_sub_expression()

  piClick: ->
    @updateCurrentExpressionWithCommand @math.commands.build_append_pi()

class_mixer(Calculator)

class ButtonLayout
  initialize: ((@components, @buttonsToRender=false)->)
  render: (@element)->
    defaultButtons = [
        "square", "square_root", "exponent", "clear",
        "pi", "lparen", "rparen", "division",
        '7', '8', '9', "multiplication",
        '4', '5', '6', "subtraction",
        '1', '2', '3', "addition",
        '0', "decimal", "negative", "equals"
      ]
    @renderComponents(@buttonsToRender || defaultButtons)

  render_component: (comp)->
    @components[comp].render element: @element

  renderComponents: (components)->
    for comp in components
      @render_component comp

class_mixer(ButtonLayout)


class CalculatorView
  initialize: (@calc, @element, @math, @buttonsToRender)->

    math_button_builder = math_buttons_lib.build
      element: @element
      ui_elements: ui_elements

    # for button layout
    buttons = {}


    numbers = math_button_builder.base10Digits click: (val)=>@calc.numberClick(val)
    for num in [0..9]
      buttons["#{num}"] = numbers[num]

    buttons.negative = math_button_builder.negative click: => @calc.negativeClick()
    buttons.decimal = math_button_builder.decimal click: => @calc.decimalClick()
    buttons.addition = math_button_builder.addition click: => @calc.additionClick()
    buttons.multiplication = math_button_builder.multiplication click: => @calc.multiplicationClick()
    buttons.division = math_button_builder.division click: => @calc.divisionClick()
    buttons.subtraction = math_button_builder.subtraction click: => @calc.subtractionClick()
    buttons.equals = math_button_builder.equals click: => @calc.equalsClick()

    buttons.clear = math_button_builder.clear click: => @calc.clearClick()
    buttons.square = math_button_builder.square click: => @calc.squareClick()
    buttons.square_root = math_button_builder.root click: => @calc.squareRootClick()
    buttons.exponent = math_button_builder.caret click: => @calc.exponentClick()

    buttons.lparen = math_button_builder.lparen click: => @calc.lparenClick()
    buttons.rparen = math_button_builder.rparen click: => @calc.rparenClick()
    buttons.pi = math_button_builder.pi click: => @calc.piClick()

    @layout = ButtonLayout.build(buttons, @buttonsToRender)

    @render()

  display: (content)->
    disp = @element.find("figure.calculator-display")
    disp.html(content)
    disp.scrollLeft(9999999)

  render: ->
    @element.append "<div class='#{calculator_wrapper_class}'></div>"
    calc_div = @element.find("div.#{calculator_wrapper_class}")
    calc_div.append "<figure class='calculator-display'>0</figure>"

    @layout.render calc_div

class_mixer(CalculatorView)


Calculator.openWidgetDialog = open_widget_dialog

ttm.widgets.Calculator = Calculator
