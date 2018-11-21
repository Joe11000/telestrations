import React from 'react'
import PropTypes from 'prop-types'
import LoadingIcon from 'images/loading_icon.gif'

export default class LoadingContainer extends React.Component {
  render() {
    let message_to_user = '';

    switch(this.props.user_status){
      case "waiting":
        message_to_user = 'Waiting for a card to be passed to you.'
        break;
      case 'finished':
        message_to_user = 'You are finished. Waiting for others to finish.';
        break;
    }
    let message_to_user__element = <h2 className='text-center mt-5'>{message_to_user}</h2>

    let LoadingIconIMG = <div className='text-center mt-5'><img src={LoadingIcon} src='/assets/loading_icon.gif' /></div>

    return (
      <div className='loading-container'>
        {message_to_user__element}
        {LoadingIconIMG}
      </div>
    )
  }
}


LoadingContainer.propTypes = {
  user_status: PropTypes.PropTypes.oneOf(['waiting', 'finished'])
}
