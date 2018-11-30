import React from 'react'
import Proptypes from 'prop-types'

export default class OutOfGameCardUploadTab extends React.Component {
  constructor(props){
    super(props);
  }

  componentDidMount(){
    this.retrieveOutOfGameCards();
  }

  render(){
    return(
      <div>
        <h3 className='card-title'>Out of Game Card Uploads Results</h3>

        <SlideshowList decks={this.state.out_of_game_card_uploads} />
      </div>
    );
  }
}


OutOfGameCardUploadTab.propTypes = {

}
