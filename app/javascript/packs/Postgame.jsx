import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'

class Postgame extends React.Component {

  constructor(props) {
    super(props);
    this.state = {

    };
  }


  // input: json from updates broadcasted from in_game_card_uploads_controller#create
  decipherData(channelData) {

    // if state is meant for user, then save data to state
    var _statuses = channelData.statuses
    for(var i in _statuses) {

      // this user is waiting and broadcast is intended for this user
      if( this.state.user_status == 'waiting' && _statuses[i].attention_users.includes(this.props.data.current_user_id) ) {
        this.setState({
                        previous_card: _statuses[i].previous_card,
                        user_status: _statuses[i].user_status
                      })
      }
    }
  }

  renderSection(status) {

  }

  render() {
    return (
      <div data-id='postgame-component'>
        <div class=''>
          {this.props}
        </div>
        <div class='clearfix'>
      </div>




    )
  }
}





document.addEventListener('DOMContentLoaded', () => {
  const node = document.querySelector("[data-id='postgames-page-data']")
  const data = JSON.parse(node.getAttribute('data'))

  ReactDOM.render(
    <Postgame data={data}/>,
    document.querySelector("[data-id='postgames-page-data']")
  )
});

Postgame.propTypes =  {

                      }
  // - unless @out_of_game_card_upload.blank?
  //   h3.h3#out_of_game_card_upload-header.text-center = "Unassociated Cards I've uploaded"
  //   .out_of_game_card_upload-i-uploaded
  //     - carousel_id = "out_of_game_card_upload"
  //     .carousel.slide data-ride='carousel' data-interval='false' id=carousel_id
  //       /! Wrapper for slides
  //       .carousel-inner role="listbox"
  //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
  //           .item class=(card_container_index == 0 ? 'active' : '')
  //             = image_tag card_container.drawing.url, alt: 'User Drawing'

  //       /! Controls
  //       a.left.carousel-control data-slide='prev' href="##{carousel_id}" role='button'
  //         i.glyphicon.glyphicon-chevron-left.fa.fa-chevron-left aria-hidden='true'
  //         span.sr-only Previous
  //       a.right.carousel-control data-slide='next' href="##{carousel_id}" role='button'
  //         i.glyphicon.glyphicon-chevron-right.fa.fa-chevron-right aria-hidden='true'
  //         span.sr-only Next
  //       /! Indicators
  //       ol.carousel-indicators
  //         - @out_of_game_card_upload.each_with_index do |card_container, card_container_index|
  //           li data-slide-to="#{card_container_index}" data-target="##{carousel_id}" class=(card_container_index == 0 ? 'active' : '')
  //     hr


  // .col-12.col-sm-12.text-center
  //   - if @arr_of_postgame_card_sets.blank?
  //     h3.h3 No Games Have Been Played

  //   - else
  //     h3.h3.text-center All Games I've played
  //     h6.h6.text-center.glow = "( Colored 'Created By' cards were made by you. )"
  //     = render partial: 'shared/card_slideshow', locals: { arr_of_postgame_card_sets: @arr_of_postgame_card_sets}
