import React from 'react'
import PropTypes from 'prop-types'
import Slideshow from './Slideshow'
// import LoadingIcon from 'images/loading_icon.gif'

export default class SlideshowList extends React.Component {
  constructor(props){
    super(props);
    // debugger
  }

  render() {
    debugger
    return (
      <div id='slideshow-list'>
      {this.props.arr_of_postgame_card_set && this.props.arr_of_postgame_card_set.map(function(deck, index){
        <Slideshow deck={deck} />
      })}
      </div>
    )
  }
}

SlideshowList.propTypes = {}
