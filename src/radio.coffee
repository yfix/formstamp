angular
.module("angular-w")
.directive "wRadio", ['$window', ($window) ->
    restrict: "A"
    scope:
      items: '='
      limit: '='
      keyAttr: '@'
      valueAttr: '@'
    require: '?ngModel'
    replace: true
    transclude: true
    templateUrl: "/templates/radio.html"
    controller: ($scope, $element, $attrs) ->

      move = (d) ->
        items = $scope.shownItems
        activeIndex = getActiveIndex() + d
        activeIndex = Math.min(Math.max(activeIndex,0), items.length - 1)
        $scope.activeItem = items[activeIndex]
        scrollIfNeeded(activeIndex)

      scrollIfNeeded = (activeIndex) ->
        ul = $element.find('ul')[0]
        li = ul.querySelector('li.active')

        return unless ul and li

        viewport =
          top: ul.scrollTop
          bottom: ul.scrollTop + innerHeightOf(ul)

        li = ul.querySelector('li.active')
        liHeight = innerHeightOf(li)
        item =
          top: activeIndex * liHeight
          bottom: (activeIndex + 1) * liHeight

        # Scroll down
        if item.bottom > viewport.bottom
          ul.scrollTop += item.bottom - viewport.bottom
          # Scroll up
        else if item.top < viewport.top
          ul.scrollTop -= viewport.top - item.top

      $scope.selection = (item)->
        $scope.selectedItem = item

      $scope.onkeys = (event)->
        switch event.keyCode
          when 40
            move(1)
            event.preventDefault()
          when 38
            move(-1)
            event.preventDefault()
          when 13
            $scope.selection($scope.activeItem)
            $scope.focus=true
            event.preventDefault()
          when  9 then $scope.selection($scope.activeItem)
          when 27
            $scope.hideDropDown()
            $scope.focus=true
          when 34
            move(11)
            event.preventDefault()
          when 33
            move(-11)
            event.preventDefault()

      $scope.$watch 'active', (value) ->
        window.setTimeout((()-> scrollIfNeeded(getActiveIndex())) , 0) if value

      getActiveIndex = ->
        ($scope.shownItems.indexOf($scope.activeItem) || 0)

      $scope.shownItems = $scope.items

      # run

    compile: (tElement, tAttrs) ->
      tAttrs.keyAttr ||= 'id'
      tAttrs.valueAttr ||= 'label'

      # Link function
      (scope, element, attrs, ngModelCtrl, transcludeFn) ->

        if ngModelCtrl
          scope.$watch 'selectedItem', ->
            ngModelCtrl.$setViewValue(scope.selectedItem)
            scope.activeItem = scope.selectedItem

          ngModelCtrl.$render = ->
            scope.selectedItem = ngModelCtrl.$modelValue

        attrs.$observe 'disabled', (value) ->
          scope.disabled = value

        attrs.$observe 'required', (value) ->
          scope.required = value

        scope.$watch 'selectedItem', ->
          childScope = scope.$new()
          childScope.item = scope.selectedItem
          transcludeFn childScope, (clone) ->
            if clone.text().trim() isnt ""
              link = element[0].querySelector('a.w-chz-active')
              angular.element(link).empty().append(clone)

        # Hide drop down list on click elsewhere
        $window.addEventListener 'click', (e) ->
          parent = $(e.target).parents('div.w-chz')[0]
          if parent != element[0]
            scope.$apply(scope.hideDropDown)
  ]