import React from 'react'
import PropTypes from 'prop-types'
import Slideshow from './Slideshow'
// import LoadingIcon from 'images/loading_icon.gif'

export default class SlideshowList extends React.Component {
  constructor(props){
    super(props);
  }

  render() {
    return (
      <div>
        <Slideshow deck='' />
        <Slideshow deck='' />
        <Slideshow deck='' />
      </div>
    )
  }
}

SlideshowList.propTypes = {}
