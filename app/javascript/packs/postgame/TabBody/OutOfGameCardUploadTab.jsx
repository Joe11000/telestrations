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
      <React.Fragment>
      { !!this.props.all_postgames_of__current_user &&

        <React.Fragment>
          <CardTitle>Your Drawings</CardTitle>
    
          <div className='mt-4 mb-4'></div>
          <SlideshowList arr_of_postgame_card_set={this.props.arr_of_postgame_card_set}
                        current_user_info={this.props.current_user_info}
                          />
        </React.Fragment>
      }
    </React.Fragment>
    );
  }
}


OutOfGameCardUploadTab.propTypes = {

}
