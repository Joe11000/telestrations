import React from 'react';
import { shallow } from 'enzyme';
// import TestRenderer from 'react-test-renderer';
import SlideshowList from 'packs/postgame/SlideshowList';
import {mock_games_index_request} from '../mock_games_index_request';

describe('SlideshowList component', () => {
  beforeEach(() => {
    debugger
    const props = { arr_of_decks_of_cards: mock_games_index_request.arr_of_postgame_card_set, 
      current_user_info: mock_games_index_request.current_user_info }
    this.props2 = props;
  })

  it('renders', () => {
    debugger
    const props = { arr_of_decks_of_cards: mock_games_index_request.arr_of_postgame_card_set, 
      current_user_info: mock_games_index_request.current_user_info, 
      needsAKeyBasedOnCardIds: true
     };

    const slideshow_component = mount(<Slideshow {...props} />);


    const slideshowlist = shallow(<SlideshowList {...props} />)

      debugger
    expect( slideshowlist.contains('.card') ).toBeDefined();

  });
});

xit("current_user's card is glowing in each slideshow", () => {
  const props_1 = { deck: mock_games_index_request.arr_of_decks_of_cards[0], 
                    current_user_info: mock_games_index_request.current_user_info, 
                    needsAKeyBasedOnCardIds: true };
  const slideshow_component_1 = mount(<Slideshow {...props_1} />);
  expect(slideshow_component_1.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(true);
  expect(slideshow_component_1.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(false);
  expect(slideshow_component_1.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(false);

  const props_2 = { deck: mock_games_index_request.arr_of_decks_of_cards[1], 
                    current_user_info: mock_games_index_request.current_user_info, 
                    needsAKeyBasedOnCardIds: true }
  const slideshow_component_2 = mount(<Slideshow {...props_2} />);
  expect(slideshow_component_2.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(false);
  expect(slideshow_component_2.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(true);
  expect(slideshow_component_2.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(false);


  const props_3 = { deck: mock_games_index_request.arr_of_decks_of_cards[2], 
                    current_user_info: mock_games_index_request.current_user_info, 
                    needsAKeyBasedOnCardIds: true }
  const slideshow_component_3 = mount(<Slideshow {...props_3} />);
  expect(slideshow_component_3.find('.carousel .carousel-item').at(0).hasClass('glow')).toEqual(false);
  expect(slideshow_component_3.find('.carousel .carousel-item').at(1).hasClass('glow')).toEqual(false);
  expect(slideshow_component_3.find('.carousel .carousel-item').at(2).hasClass('glow')).toEqual(true);
});

// test('adds 1 + 2 to equal 3', () => {
//   expect(1).toEqual(1);
// });
