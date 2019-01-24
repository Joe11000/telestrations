import React, { Component } from 'react';
import {
  Carousel,
  CarouselItem,
  CarouselControl,
  CarouselIndicators,
  // CarouselCaption
} from 'reactstrap';

import {
  Card,
  CardText,
  CardBody, 
  CardTitle, 
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
  }

  acquireCardInfoForCarousel(deck) {
    return deck.map((card_info, index) => {
      if(card_info[1].medium === 'description'){
        return({
                src: '',
                altText: card_info[1].description_text,
                caption: `By: ${card_info[0]}`
              });
      }
      else if (card_info[1].medium === 'drawing') {
      return({
                src: card_info[1].drawing_url,
                altText: '',
                caption: `By: ${card_info[0]}`
            });
      }
      else {
        throw new Error('Card must be a drawing or a description');
      }
    });
  }

  next() {
    const num_of_cards = this.props.deck.length;
    if (this.animating) return;
    const nextIndex = this.state.activeIndex === num_of_cards - 1 ? 0 : this.state.activeIndex + 1;
    this.setState({ activeIndex: nextIndex });
  }

  previous() {
    const num_of_cards = this.props.deck.length;

    if (this.animating) return;
    const nextIndex = this.state.activeIndex === 0 ? num_of_cards - 1 : this.state.activeIndex - 1;
    this.setState({ activeIndex: nextIndex });
  }

  goToIndex(newIndex) {
    if (this.animating) return;
    this.setState({ activeIndex: newIndex });
  }

  render() {
    const { deck, list_item_index } = this.props;
    const { activeIndex } = this.state;

    const carousel_card_info = this.acquireCardInfoForCarousel(deck);

    const slides = carousel_card_info.map(function(item, slide_index) {
      const conjoined_card_id = deck[slide_index][1].id;
      
      return (
          <CarouselItem key={ `carousel-item-${conjoined_card_id}` } >
            <Card className='bg-dark border-primary m-auto' style={{"height": '300px'}}>
              {
                item.src ? <CardImg top className="d-block h-100" src={item.src} alt={item.altText } />
                          : undefined
              }
              
              <CardBody style={{'display': 'flex',  justifyContent: 'center', alignItems: 'center'}}>
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
      
      <Carousel
        autoplay={false}
        activeIndex={activeIndex}
        next={this.next}
        previous={this.previous}
        interval={false}
      >
        <CarouselIndicators items={carousel_card_info} activeIndex={activeIndex} onClickHandler={this.goToIndex} />
        {slides}
        <CarouselControl direction="prev" directionText="Previous" onClickHandler={this.previous} />
        <CarouselControl direction="next" directionText="Next" onClickHandler={this.next} />
      </Carousel>
    );
  }
}

export default Slideshow;