import React from 'react';
import PropTypes from 'prop-types';

export default class OutOfGameCardUploadTab extends React.Component {
  constructor(props){
    super(props);
    this.retrieveOutOfGameCards = this.retrieveOutOfGameCards.bind(this);

    this.state = {outOfGameCards: []};
  }

  componentDidMount(){
    debugger
    this.retrieveOutOfGameCards();
  }

  render(){
    const {retrieveOutOfGameCards} = this.state;
    const outOfGameCards = retrieveOutOfGameCards;
    debugger;

    return(
      <React.Fragment>
      { !!this.props.outOfGameCards &&

        <React.Fragment>
          <CardTitle>Your Drawings</CardTitle>
    
          <div className='mt-4 mb-4'></div> 
          <SlideshowList arr_of_decks_of_cards={outOfGameCards}
                         current_user_info={this.props.current_user_info}
                          />
        </React.Fragment>
      }
    </React.Fragment>
    );
  }

  retrieveOutOfGameCards(){
    $.getJSON(`/cards/out_of_game_card_uploads`, function(response) {
      // let edited_response = Object.assign(response, {tab_selected: 'OutOfGameCardUploadTab'} );
      // this.setState(edited_response);
      this.setState(response);
    }.bind(this));
  }
}


OutOfGameCardUploadTab.propTypes = {
  outOfGameCards: PropTypes.arrayOf(PropTypes.object), 
  current_user_info: PropTypes.shape({
    id: PropTypes.number, 
    name: PropTypes.string,
  })
}
