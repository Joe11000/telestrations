import React from 'react';
import PropTypes from 'prop-types';
import Slideshow from './Slideshow';
// import $ from 'jquery'
import { ListGroup, ListGroupItem } from 'reactstrap';

// import LoadingIcon from 'images/loading_icon.gif'

export default class SlideshowList extends React.Component {
  render() {
    var current_user_info = this.props.current_user_info;
    
    const {arr_of_postgame_card_set, } = this.props;

    return (
      <ListGroup flush>
        {
          arr_of_postgame_card_set && arr_of_postgame_card_set.map(function(deck){
            const first_card_in_the_game = deck.map(deck => deck[1].id).join('.')

            return (
              <ListGroupItem  className="list-group-item" key={`list-group-item-${first_card_in_the_game}`} >
                <Slideshow deck={deck} current_user_info={current_user_info} />
              </ListGroupItem>
            )
          })
        }
      </ListGroup>
    )
  }

}
SlideshowList.propTypes = {
  arr_of_postgame_card_set: PropTypes.array
}

