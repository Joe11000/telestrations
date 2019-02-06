import React from 'react';
import PropTypes from 'prop-types';
import Slideshow from './Slideshow';
// import $ from 'jquery'
import { ListGroup, ListGroupItem } from 'reactstrap';

// import LoadingIcon from 'images/loading_icon.gif'

export default class SlideshowList extends React.Component {
  render() {
    var {arr_of_decks_of_cards, current_user_info} = this.props;    

    return (
      <ListGroup flush>
        {
          arr_of_decks_of_cards && arr_of_decks_of_cards.map(function(deck, index){
            const first_card_in_the_game = deck.map(deck => deck[1].id).join('.')

            return (
              <ListGroupItem  className="list-group-item" key={`list-group-item-${first_card_in_the_game}`} accessKey={index}>
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
  arr_of_decks_of_cards: PropTypes.array
}
