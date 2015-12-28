@Artoo.module 'HeaderApp.List', (List, App, Backbone, Marionette, $, _) ->
  
  class List.Layout extends App.Views.LayoutView
    template: 'header/list/list_layout'
    
    regions:
      topBarRegion: '#top-bar-region'
      titleRegion:  '#title-region'
  
  
  class List.Nav extends App.Views.ItemView
    tagName: 'li'
    
    getTemplate: ->
      if @model.isDivider() then false else 'header/list/_nav'
      
    onRender: ->
      @$el.addClass 'divider' if @model.isDivider()
      
    @include 'Selectable'
    
  
  class List.TopBar extends App.Views.CompositeView
    template:           'header/list/top_bar'
    childView:          List.Nav
    childViewContainer: '#nav-links'
    
    triggers:
      'click #sign-in' : 'sign:in:clicked'
      
  class List.Title extends App.Views.ItemView
    template: 'header/list/title'
    
    collectionEvents:
      'select:one' : 'render'
      
    serializeData: ->
      'name' : @collection.selected?.get('name')
      'icon' : @collection.selected?.get('icon')