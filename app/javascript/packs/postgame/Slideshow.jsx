import React, { Component } from 'react';
import PropTypes from 'prop-types';

import {
  Carousel,
  CarouselItem,
  CarouselControl,
  CarouselIndicators,
} from 'reactstrap';

import {
  Card,
  CardBody, 
  CardImg,
} from 'reactstrap';


class Slideshow extends Component {
  constructor(props) {
    super(props);
    this.next = this.next.bind(this);
    this.previous = this.previous.bind(this);
    this.goToIndex = this.goToIndex.bind(this);
    this.acquireCardInfoForCarousel = this.acquireCardInfoForCarousel.bind(this);
    this.state = {
                   activeIndex: 0
                 };
    this.currentSlideshow = React.createRef();
    
  }

  componentDidMount() {

    // turn the indicator red of the card the current_user drew. Current slideshow only
    let deck_length = this.props.deck.length;
    for(let card_index = 0; card_index < deck_length; card_index++) {
      let carousel_indicators = this.currentSlideshow.current.querySelector('.carousel-indicators');

      if(this.props.current_user_info.id == this.props.deck[card_index][1].uploader_id) {  
        let card_the_current_user_made = carousel_indicators.childNodes[card_index];
        card_the_current_user_made.style.backgroundColor = 'red';
        break;
      }
    }
  }

  acquireCardInfoForCarousel(deck) {
    return deck.map(function (card_info)  {
      const {current_user_info} = this.props;
      // Show text in different color if this card created by the current user
      const shouldGlow = (current_user_info && current_user_info.id) == card_info[1].uploader_id;
      
      if(card_info[1].medium === 'description'){
        return({
                src: '',
                altText: card_info[1].description_text,
                caption: `By: ${card_info[0]}`,
                shouldGlow 
              });
      }
      else if (card_info[1].medium === 'drawing') {
      return({
                src: card_info[1].drawing_url,
                altText: '',
                caption: card_info[0] ? `By: ${card_info[0]}` : '', // don't show caption if drawing was uploaded out of game
                shouldGlow
            });
      }
      else {
        throw new Error('Card must be a drawing or a description');
      }
    }.bind(this));
  }

  next() {
    const num_of_cards = this.props.deck.length;
    const { activeIndex } = this.state;

    if (this.animating) return;
    const nextIndex = activeIndex === num_of_cards - 1 ? 0 : activeIndex + 1;
    this.setState({ activeIndex: nextIndex });
  }

  previous() {
    const num_of_cards = this.props.deck.length;
    const { activeIndex } = this.state;

    if (this.animating) return;
    const nextIndex = activeIndex === 0 ? num_of_cards - 1 : activeIndex - 1;
    this.setState({ activeIndex: nextIndex });
  }

  goToIndex(newIndex) {
    if (this.animating) return;
    this.setState({ activeIndex: newIndex });
  }

  render() {
    debugger
    const { deck } = this.props;
    const { activeIndex } = this.state;

    const carousel_card_info = this.acquireCardInfoForCarousel(deck);

    const slides = carousel_card_info.map(function(item, slide_index) {

      const conjoined_card_id = deck[slide_index][1].id;
      
      const card_body_styles = {display: 'flex',  justifyContent: 'center', alignItems: 'center'};
      
      return (
          <CarouselItem key={ `carousel-item-${conjoined_card_id}` } className={ item.shouldGlow ? 'glow' : ''} >
            <Card className='bg-dark border-primary m-auto' style={{"height": '300px'}}>
              {
                item.src ? <CardImg top className="d-block h-100" src={item.src} alt={item.altText } />
                          : undefined
              }
              
              <CardBody style={ card_body_styles } >
                <div style={{flex: 1}}>
                  <div className='d-xs-none'>
                    <p className='h3'>{item.altText}</p>
                    <p className="h5">{item.caption}</p>
                  </div>

                  <div className='d-sm-none'>
                    <p className='h4'>{item.altText}</p>
                    <p className="h6">{item.caption}</p>
                  </div>
                </div>
              </CardBody>
            </Card>
          </CarouselItem>
      );
    }.bind(this))
    
    return (
      <div ref={this.currentSlideshow}>
        <Carousel
          autoplay={false}
          activeIndex={activeIndex}
          next={this.next}
          previous={this.previous}
          interval={false}
          >
          <CarouselIndicators items={carousel_card_info} activeIndex={activeIndex} onClickHandler={this.goToIndex}/>
          {slides}
          <CarouselControl direction="prev" directionText="Previous" onClickHandler={this.previous} />
          <CarouselControl direction="next" directionText="Next" onClickHandler={this.next} />
        </Carousel>
      </div>
    );
  }
}

Slideshow.propTypes = {
  current_user_info: PropTypes.shape({
    id: PropTypes.number, 
    name: PropTypes.string,
  }).isRequired,
  deck: PropTypes.array.isRequired
}
export default Slideshow;