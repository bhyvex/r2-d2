@Artoo.module 'Components.FormFields', (FormFields, App, Backbone, Marionette, $, _) ->
  
  
  # Form input views
  
  
  class FormFields.BaseInputView extends App.Views.ItemView
    template: 'form_fields/input'
    
    attributes: ->
      class: 'row'
      id:    @model.get('elementId')
      style: if @model.isShown() then 'display:block;' else 'display:none;'
    
    ui: ->
      input: "#{@getTagName()}[name^='#{@getNameAttr()}']"
      
    getTagName: ->
      @model.get 'tagName'
      
    getNameAttr: ->
      @model.get 'name'
    
    events:
      'change @ui.input' : 'updateModelValue'
      
    updateModelValue: ->
      @model.set 'value', @currentValue()
      
      @trigger 'value:changed', @getNameAttr(), @currentValue()
      
    currentValue: ->
      Backbone.Syphon.serialize(@el)[@getNameAttr()]
      
    @include 'DynamicFormView'
  
  
  class FormFields.TextFieldView extends FormFields.BaseInputView
  
  
  class FormFields.NumberFieldView extends FormFields.BaseInputView
    
  
  class FormFields.TextAreaView extends FormFields.BaseInputView
    template: 'form_fields/textarea'
  
        
  class FormFields.SelectView extends FormFields.BaseInputView
    template: 'form_fields/select'
  
  
  class FormFields.CollectionCheckBoxesView extends FormFields.BaseInputView
    template: 'form_fields/collection_check_boxes'
    
  
  class FormFields.RadioButtonsView extends FormFields.BaseInputView
    template: 'form_fields/radio_buttons'
  
  
  class FormFields.CollectionRadioButtonsView extends FormFields.BaseInputView
    template: 'form_fields/collection_radio_buttons'
  
  
  # Form fieldset views
  
  
  class FormFields.FieldsetView extends App.Views.CompositeView
    template:           'form_fields/fieldset'
    tagName:            'fieldset'
    childViewContainer: '.fields'
    
    attributes: ->
      id:    @model.get('elementId')
      style: if @model.isShown() then 'display:block;' else 'display:none;'
    
    getChildView: (model) ->
      return FormFields.TextFieldView              if model.get('tagName') is 'input'  and model.get('type') is 'text'
      return FormFields.NumberFieldView            if model.get('tagName') is 'input'  and model.get('type') is 'number'
      return FormFields.CollectionCheckBoxesView   if model.get('tagName') is 'input'  and model.get('type') is 'collection_check_boxes'
      return FormFields.RadioButtonsView           if model.get('tagName') is 'input'  and model.get('type') is 'radio_buttons'
      return FormFields.CollectionRadioButtonsView if model.get('tagName') is 'input'  and model.get('type') is 'collection_radio_buttons'
      return FormFields.SelectView                 if model.get('tagName') is 'select'
      return FormFields.TextAreaView               if model.get('tagName') is 'textarea'
      
    @include 'DynamicFormView'
  
  
  class FormFields.FieldsetCollectionView extends App.Views.CollectionView
    childView: FormFields.FieldsetView
        
    buildChildView: (child, childViewClass, childViewOptions) ->
      new FormFields.FieldsetView
        model:      child
        collection: child.fields