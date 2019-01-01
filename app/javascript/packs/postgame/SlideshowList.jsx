import React from 'react'
import PropTypes from 'prop-types'
import Slideshow from './Slideshow'
import $ from 'jquery'
import { ListGroup, ListGroupItem } from 'reactstrap';

// import LoadingIcon from 'images/loading_icon.gif'

export default class SlideshowList extends React.Component {

  render() {
    var that_props = this.props;

    return (
      <ListGroup flush>
        {
          this.props.arr_of_postgame_card_set && this.props.arr_of_postgame_card_set.map(function(deck, index){
            return (
              <ListGroupItem  class="list-group-item" key={`list-group-item-${index}`}>
                <Slideshow deck={deck} current_user_info={that_props.current_user_info} key_preface={`slideshow-${index}`} />
              </ListGroupItem>
            )
          })
        }
      </ListGroup>
    )
  }
}

