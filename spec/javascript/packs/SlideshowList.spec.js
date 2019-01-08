import React from 'react';
import { shallow } from 'enzyme';
// import TestRenderer from 'react-test-renderer';
import SlideshowList from 'packs/postgame/SlideshowList';
import mock_games_index_request from '../mock_games_index_request';

describe('SlideshowList component', () => {
  test('renders', () => {
    const props = mock_games_index_request
    const postgame = shallow(<SlideshowList {...props} />)

    expect( postgame.contains('.card') ).toBeDefined();

  });

  // describe('while on the page', ()=>{
  //   describe('selects a different game in the dropdown selector', ()=>{
  //     it("", ()=>{
  //       expect(1).toEqual(1)
  //     })
  //   })

  //   describe('selects the same game in the dropdown selector', ()=>{
  //     it("doesn't get other ", ()=>{
  //       expect(1).toEqual(1)

  //     })
  //   })
  // });

});

// test('adds 1 + 2 to equal 3', () => {
//   expect(1).toEqual(1);
// });
